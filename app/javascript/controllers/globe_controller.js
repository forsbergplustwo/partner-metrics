import { Controller } from "@hotwired/stimulus"
import Globe from "globe.gl"
import {
  Color,
  DirectionalLight,
  Fog,
  PointLight,
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
  ["rgba(35, 196, 140, 0.5)", "rgba(35, 196, 140, 0.7)", "rgba(161, 237, 208, 0.9)", "rgba(161, 237, 208, 1)"],
  ["rgba(59, 195, 211, 0.5)", "rgba(59, 195, 211, 0.7)", "rgba(147, 222, 231, 0.9)", "rgba(147, 222, 231, 1)"],
  ["rgba(121, 69, 227, 0.5)", "rgba(121, 69, 227, 0.7)", "rgba(203, 180, 248, 0.9)", "rgba(203, 180, 248, 1)"]
]
const ARC_ALTITUDES = [0.5, 0.55, 0.55, 0.6, 0.6];
const ARC_DASH_LENGTHS = [1.5, 1.8, 1.9, 1.9, 2, 2.2];
const ARC_SPEEDS = [0.6, 0.65, 0.75, 0.95, 1];

export default class extends Controller {
  static targets = ['container']
  static values = {
    countriesCount: {
      Number,
      default: 50
    },
    paymentCountries: {
      type: Array,
      default: []
    },
    myLocation: {
      type: String,
      default: "DK"
    }
  }

  initialize() {
    this.globe = Globe()

    this.setupGlobe();
    this.setupScene();
    this.setupControls();
    this.setupCamera();

    this.setSize();
    this.setViewPointCountry();
  }

  connect() {
    // Add dataFetcher() here
    this.setSize();
    this.globe.resumeAnimation();
    this.globe.showGlobe(true);
    this.emitArcs();
  }

  disconnect() {
    this.globe.showGlobe(false);
    this.globe.pauseAnimation();
  }

  // ACTIONS

  emitArcs() {
    // Generate arcsData based on provided countries and my location
    const myLat = CountryData[this.myLocationValue].lat
    const myLng = CountryData[this.myLocationValue].lon

    const selectedCountries = this.paymentCountriesValue.slice(0, this.countriesCountValue)
      .map(code => CountryData[code])
      .filter(Boolean);

    const arcsData = selectedCountries.map(country => ({
      startLat: country.lat,
      startLng: country.lon,
      endLat: myLat,
      endLng: myLng,
      arcColor: ARC_COLORS[Math.round(Math.random() * (ARC_COLORS.length - 1))],
      arcAltitude: ARC_ALTITUDES[Math.round(Math.random() * (ARC_ALTITUDES.length - 1))] * 1.2,
      arcDashLength: ARC_DASH_LENGTHS[Math.round(Math.random() * (ARC_DASH_LENGTHS.length - 1))],
      arcSpeed: ARC_SPEEDS[Math.round(Math.random() * (ARC_SPEEDS.length - 1))] * FLIGHT_TIME
    }));

    // Emit arcs in a tightly controlled time loop
    // Cycle speed is proportional to arc length,
    // total flight time & dashLength.. very important!
    let currentArcIndex = 0;
    const emitLoop = () => {
      let arc = arcsData[currentArcIndex];
      let cycleSpeed = arc.arcSpeed * arc.arcDashLength;
      this.emitArc(arc, cycleSpeed);
      currentArcIndex = (currentArcIndex + 1) % arcsData.length;
      setTimeout(emitLoop, cycleSpeed * 2);
    };

    // Start the emit loops with a small delay
    // Add more for more arcs at once
    setTimeout(() => {
      emitLoop();
      setTimeout(emitLoop, 800);
      setTimeout(emitLoop, 1400);
      setTimeout(emitLoop, 2300);
    }, 500);
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
      .hexPolygonColor((e) => {
        if (
          ["DK"].includes(
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
    const MATERIAL_COLOR = new Color(0x16042D);
    const MATERIAL_EMISSIVE_COLOR = new Color(0x000000);


    const globeMaterial = this.globe.globeMaterial();
    globeMaterial.color = MATERIAL_COLOR
    globeMaterial.specular = MATERIAL_COLOR
    globeMaterial.emissive = MATERIAL_EMISSIVE_COLOR
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
    controls.autoRotateSpeed = 0.35;
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

  setViewPointCountry() {
    let dk = CountryData.DK
    const lat = dk.lat
    const lng = dk.lon

    const pointOfView = {
      lat: lat - 15,
      lng: lng + 45,
      altitude: 2.5
    };
    setTimeout(() => { this.globe.pointOfView(pointOfView) });
  }

  setSize() {
    this.globe.width(this.containerSize.width);
    this.globe.height(this.containerSize.height);
  }

  get containerSize() {
    let dimensions = this.containerTarget.getBoundingClientRect();
    return { width: dimensions.width, height: dimensions.height };
  }
}
