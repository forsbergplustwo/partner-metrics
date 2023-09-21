import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import Globe from "globe.gl"
import {
  Color,
  DirectionalLight,
  Fog,
  PointLight
} from "three"

import map from "../libraries/globe/countries-map-data.json";
import { CountryData } from "../libraries/globe/country-data";

// CONSTANTS
const ARC_REL_LEN = 3.2; // relative to whole arc
const FLIGHT_TIME = 1000;
const NUM_RINGS = 4;
const RINGS_MAX_R = 1.2; // deg
const RING_PROPAGATION_SPEED = 0.3; // deg/sec

const ARC_COLORS = [
  ["rgba(80, 220, 169, 0.5);", "rgba(80, 220, 169, 0.7);", "rgba(161, 237, 208, 0.9)", "rgba(161, 237, 208, 1)"],
  ["rgba(109, 211, 222, 0.5)", "rgba(109, 211, 222, 0.7)", "rgba(147, 222, 231, 0.9)", "rgba(147, 222, 231, 1)"],
  ["rgba(173, 139, 241, 0.5)", "rgba(173, 139, 241, 0.7)", "rgba(203, 180, 248, 0.9)", "rgba(203, 180, 248, 1)"]
]
const ARC_REVERSED_COLORS = [
  ["rgba(245, 196, 82, 0.5)", "rgba(245, 196, 82, 0.7)", "rgba(248, 217, 144, 0.9)", "rgba(248, 217, 144, 1)"],
  ["rgba(245, 147, 82, 0.5)", "rgba(245, 147, 82, 0.7)", "rgba(247, 177, 130, 0.9)", "rgba(247, 177, 130, 1)"],
]

const ARC_ALTITUDES = [0.5, 0.55, 0.55, 0.6, 0.6];
const ARC_DASH_LENGTHS = [1.5, 1.8, 1.9, 1.9, 2, 2.2];
const ARC_SPEEDS = [0.6, 0.65, 0.75, 0.95, 1];

const ARCS_AT_ONCE = 6;
const ARC_EMIT_DELAY = 300;

export default class extends Controller {
  static targets = ['container']
  static values = {
    myLocation: {
      type: String,
      default: "US"
    },
    fetchUrl: {
      type: String,
    },
    keepFetching: {
      type: Boolean,
      default: true
    }
  }

  initialize() {
    this.globe = Globe()
    this.setupGlobe();
    this.setupScene();
    this.setupControls();
    this.setupCamera();

    this.setUserLocation().then(() => {
      this.updateGlobeHexPolygons();
      this.setViewPointCountry()
    })
  }


  connect() {
    this.setSize();
    this.globe.arcsData([]);
    this.globe.resumeAnimation();
    this.containerTarget.addEventListener("resize", () => this.setSize());
    this.containerTarget.style.opacity = 1;

    // Start fetching data and emitting arcs
    this.keepFetchingValue = true;
    this.previouslyFetchedArcs = []
    setTimeout(() => { this.fetchDataAndEmit(); }, 2000);
  }

  disconnect() {
    this.keepFetchingValue = false;
    this.containerTarget.style.opacity = 0;

    this.globe.pauseAnimation();
    this.containerTarget.removeEventListener("resize", () => this.setSize());
  }

  // ACTIONS

  async fetchDataAndEmit() {
    // Stop fetching if disconnected
    if (!this.keepFetchingValue) {
      return;
    }

    let delay = 3000;

    // Expecting an array of country codes and reverse flags [{ countryCode: "US", reverse: false}]
    // at some multiple of ARCS_AT_ONCE (recommended 10 * ARCS_AT_ONCE)
    const response = await get(this.fetchUrlValue);
    let newlyFetchedArcs = await response.json;

    if (response.ok && newlyFetchedArcs.length > 0) {
      // Stops emitting when no new arcs are fetched
      if (JSON.stringify(newlyFetchedArcs) === JSON.stringify(this.previouslyFetchedArcs)) {
        return;
      }
      this.previouslyFetchedArcs = newlyFetchedArcs;

      // Emit arcs in chunks (number of arcs seen at once)
      let chunkSize = Math.ceil(newlyFetchedArcs.length / ARCS_AT_ONCE);
      delay = chunkSize * FLIGHT_TIME - 1000;
      this.emitArcsInChunks(newlyFetchedArcs, chunkSize);
    }
    // Repeat again when the total arc release cycle is complete
    setTimeout(() => { this.fetchDataAndEmit(); }, delay);
  }

  emitArcsInChunks(arcs, chunkSize) {
    let delay = 0;
    const chunkedArcs = this.chunkArray(arcs, chunkSize);
    for (let i = 0; i < chunkedArcs.length; i++) {
      setTimeout(() => {
        this.emitArcs(chunkedArcs[i]);
      }, delay);
      delay += ARC_EMIT_DELAY;
    }
  }

  emitArcs(data) {
    // Generate arcsData based on provided countries and own location
    const selectedCountries = data.slice(0, data.length - 1)
      .map(payment => ({ coordinates: CountryData[payment.countryCode], reverse: payment.reverse }))
      .filter(country => country.coordinates);

    const myLat = CountryData[this.myLocationValue].lat
    const myLng = CountryData[this.myLocationValue].lon

    let arcsData = selectedCountries.map(country => this.getArcDataForCountry(country, myLat, myLng));

    // Emit arcs in a tightly controlled time loop
    // Cycle speed is proportional to arc length,
    // total flight time & dashLength.. very important!
    const emitLoop = () => {
      if (arcsData.length < 1) {
        // Stop emitting when no more arcs in the chunk
        return;
      }
      let arc = arcsData.shift();
      let cycleSpeed = arc.arcSpeed * arc.arcDashLength;
      this.emitArc(arc, cycleSpeed);
      setTimeout(emitLoop, cycleSpeed * 2);
    };

    // Start the emit loops
    emitLoop();
  }


  emitArc(arc, cycleSpeed) {
    // Add and remove arc after 1 cycle
    this.globe.arcsData([...this.globe.arcsData(), arc]);
    setTimeout(() => this.globe.arcsData(this.globe.arcsData().filter(d => d !== arc)), cycleSpeed * 4);
    // Add and remove start rings
    const srcRing = { lat: arc.startLat, lng: arc.startLng };
    this.globe.ringColor(arc.arcColor);
    this.globe.ringsData([...this.globe.ringsData(), srcRing]);
    setTimeout(() => this.globe.ringsData(this.globe.ringsData().filter(r => r !== srcRing)), cycleSpeed);
    // Add and remove target rings
    setTimeout(() => {
      const targetRing = { lat: arc.endLat, lng: arc.endLng };
      this.globe.ringColor(arc.arcColor);
      this.globe.ringsData([...this.globe.ringsData(), targetRing]);
      setTimeout(() => this.globe.ringsData(this.globe.ringsData().filter(r => r !== targetRing)), cycleSpeed);
    }, cycleSpeed);
  }

  getArcDataForCountry = (country, myLat, myLng) => {
    if (!country.coordinates) {
      return;
    }
    let startLat, startLng, endLat, endLng;

    if (country.reverse) {
      startLat = myLat;
      startLng = myLng;
      endLat = country.coordinates.lat;
      endLng = country.coordinates.lon;
    } else {
      startLat = country.coordinates.lat;
      startLng = country.coordinates.lon;
      endLat = myLat;
      endLng = myLng;
    }

    return {
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      arcColor: this.getArcColor(country.reverse),
      arcAltitude: this.getRandomFromList(ARC_ALTITUDES),
      arcDashLength: this.getRandomFromList(ARC_DASH_LENGTHS),
      arcSpeed: this.getRandomFromList(ARC_SPEEDS) * FLIGHT_TIME
    };
  };

  // SETUP GLOBE

  setupGlobe() {
    // Attach to DOM
    this.globe(this.containerTarget);

    this.addGlobeHexPolygons();
    this.addGlobeArcsLayer();
    this.addGlobeRingsLayer();
    this.addGlobeMaterials();
  }

  addGlobeHexPolygons() {
    this.globe
      .backgroundColor("#f1f2f4")//("rgba(255, 255, 255, 1)")
      .atmosphereColor("rgba(67, 21, 158, 1)")
      .showAtmosphere(true)
      .atmosphereAltitude(0.22)
      .hexPolygonsData(map.features)
      .hexPolygonResolution(3)
      .hexPolygonMargin(0.3)
      .hexPolygonColor("rgba(255,255,255, 0.3)");
  }

  updateGlobeHexPolygons() {
    this.globe.hexPolygonColor((e) => {
      if (
        this.myLocationValue.includes(
          e.properties.ISO_A2
        )
      ) {
        return "rgba(255,255,255, 0.8)";
      } else return "rgba(255,255,255, 0.3)";
    });
  }

  addGlobeArcsLayer() {
    this.globe
      .arcsData([])
      .arcColor('arcColor')
      .arcDashAnimateTime("arcSpeed")
      .arcDashLength("arcDashLength")
      .arcAltitudeAutoScale("arcAltitude")
      .arcDashGap(2)
      .arcDashInitialGap(1)
      .arcsTransitionDuration(100)
      .arcStroke(0.6)
      .arcCurveResolution(64)
      .arcCircularResolution(12)
  }

  addGlobeRingsLayer() {
    this.globe
      .ringsData([])
      .ringMaxRadius(RINGS_MAX_R)
      .ringPropagationSpeed(RING_PROPAGATION_SPEED)
      .ringRepeatPeriod(FLIGHT_TIME * ARC_REL_LEN / NUM_RINGS);
  }

  addGlobeMaterials() {
    const globeMaterial = this.globe.globeMaterial();
    globeMaterial.color = new Color(0x16042D);
    globeMaterial.emissive = new Color(0x000000);
    globeMaterial.emissiveIntensity = 0.2;
    globeMaterial.shininess = 0.7;
  }


  // SETUP SCENE

  setupScene() {
    const scene = this.globe.scene();
    scene.fog = new Fog(0x535ef3, 200, 400);
  }

  // SETUP CONTROLS

  setupControls() {
    const controls = this.globe.controls();
    controls.minPolarAngle = Math.PI / 4;
    controls.maxPolarAngle = Math.PI - Math.PI / 3.5;
    controls.enableDamping = true;
    controls.dynamicDampingFactor = 0.01;
    controls.enablePan = false;
    controls.minDistance = 140;
    controls.maxDistance = 300;
    controls.rotateSpeed = 0.2;
    controls.zoomSpeed = 0.2;
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.25;
  }

  // SETUP CAMERA

  setupCamera() {
    const camera = this.globe.camera();

    setTimeout(() => { // wait for scene to be populated (asynchronously)
      var dLight = new DirectionalLight(0xffffff, 0.8);
      dLight.position.set(-800, 2000, 400);
      camera.add(dLight);

      var dLight1 = new DirectionalLight(0x7982f6, 1);
      dLight1.position.set(-200, 500, 200);
      camera.add(dLight1);
      //
      var dLight2 = new PointLight(0x8566cc, 1);
      dLight2.position.set(-200, 500, 200);
      camera.add(dLight2);

    });
  }

  // HELPER FUNCTIONS

  async setUserLocation() {
    // Using http://ip-api.com/json/
    const response = await get("http://ip-api.com/json/?fields=countryCode");
    if (response.ok) {
      const locationData = await response.json;
      this.myLocationValue = locationData.countryCode;
    }
  }

  setViewPointCountry() {
    const myLocation = CountryData[this.myLocationValue]
    const pointOfView = {
      lat: myLocation.lat - 15,
      lng: myLocation.lon + 45,
      altitude: 2.5
    };
    setTimeout(() => { this.globe.pointOfView(pointOfView) });
  }

  setSize() {
    this.globe.width(this.containerSize.width);
    this.globe.height(this.containerSize.height);
  }

  getArcColor = (reverse) => {
    if (reverse) {
      return ARC_REVERSED_COLORS[Math.round(Math.random() * (ARC_REVERSED_COLORS.length - 1))];
    } else {
      return ARC_COLORS[Math.round(Math.random() * (ARC_COLORS.length - 1))];
    }
  };

  getRandomFromList = (list) => {
    return list[Math.round(Math.random() * (list.length - 1))];
  };

  get containerSize() {
    let dimensions = this.containerTarget.getBoundingClientRect();
    return { width: dimensions.width, height: dimensions.height };
  }

  chunkArray(array, size) {
    // This prevents infinite loops
    if (size < 1) throw new Error('Size must be positive')

    const result = []
    for (let i = 0; i < array.length; i += size) {
      result.push(array.slice(i, i + size))
    }
    return result
  }
}
