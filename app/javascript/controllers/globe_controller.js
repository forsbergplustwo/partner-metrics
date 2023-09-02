import { Controller } from "@hotwired/stimulus"
import ThreeGlobe from "three-globe";
import {
  WebGLRenderer,
  Scene,
  PerspectiveCamera,
  AmbientLight,
  DirectionalLight,
  Color,
  Fog,
  PointLight
} from "three";

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import map from "../libraries/globe/countries-map-data.json";
import { CountryData } from "../libraries/globe/country-data";

export default class extends Controller {
  static targets = ['container']


  connect() {
    this.shouldAnimate = true;
    this.initGlobe();
  }

  disconnect() {
    this.Globe._destructor();
    this.shouldAnimate = false;
    this.renderer.dispose();
    this.scene.remove(this.Globe);
    this.orbitControls.dispose();
    this.containerTarget.removeChild(this.renderer.domElement);
  }

  initGlobe() {
    this.Globe = new ThreeGlobe()
      //.globeImageUrl("//unpkg.com/three-globe/example/img/earth-water.png")
      .hexPolygonsData(map.features)
      .hexPolygonResolution(3)
      .hexPolygonMargin(0.3)
      .showAtmosphere(true)
      .atmosphereColor("rgba(67, 21, 158, 1)")
      .atmosphereAltitude(0.22)
      .hexPolygonColor((e) => {
        return "rgba(255,255,255, 0.8)";
      });
    this.renderer = new WebGLRenderer()
    this.scene = new Scene()
    this.camera = new PerspectiveCamera()
    this.orbitControls = new OrbitControls(this.camera, this.renderer.domElement)

    // Container size
    let dimensions = this.containerTarget.getBoundingClientRect();
    const width = dimensions.width;
    const height = dimensions.height;

    // RENDERER
    // Setup
    const renderer = this.renderer;
    this.renderer.setSize(width, height);
    // Attach to dom
    this.containerTarget.appendChild(this.renderer.domElement);

    // ARCS
    // Random data
    const N = 20;

    let dk = CountryData.DK
    const myLat = dk.lat
    const myLng = dk.lon
    const colors = [["#a1edd0", "#23c48c", "#16a679"],
    ["#93dee7", "#3bc3d3", "#2aacbb"],
    ["#93baf1", "#3e7dd5", "#2463bc"],
    ["#cbb4f8", "#7945e3", "#5a24cd"]]

    // Fake arcs data but with real country data
    const randomCountryKeys = Object.keys(CountryData);
    const selectedCountries = [];
    for (let i = 0; i < N; i++) {
      const randomIndex = Math.floor(Math.random() * randomCountryKeys.length);
      const randomCountry = CountryData[randomCountryKeys[randomIndex]];
      selectedCountries.push(randomCountry);
    }

    // Generate arcsData based on selected countries
    const arcsData = selectedCountries.map(country => ({
      startLat: country.lat,
      startLng: country.lon,
      endLat: myLat,
      endLng: myLng,
      color: colors[Math.round(Math.random() * 3.5)]
    }));

    // GLOBE
    const Globe = this.Globe

    // ARCS
    Globe
      .arcsData(arcsData)
      .arcColor('color')
      .arcDashLength(() => Math.random() * 1.5 + 2)
      .arcDashGap(6)
      .arcAltitudeAutoScale(() => [0.48, 0.5][Math.round(Math.random() * 2)])
      .arcDashInitialGap(() => Math.random() * 30)
      .arcDashAnimateTime(() => Math.random() * 500 + 700)
      .arcCurveResolution(64)
      .arcStroke(0.8)
      .arcCircularResolution(12)
    // Styling

    const ringRandomness = 1.2;
    const ringDefaults = {
      maxR: ringRandomness,
      propagationSpeed: ringRandomness / 2,
      repeatPeriod: ringRandomness * 1000
    }
    // RINGS
    const R = 2;
    const gData = arcsData.map((arc) => ([
      {
        lat: arc.startLat,
        lng: arc.startLng,
        color: arc.color,
        ...ringDefaults
      },
      {
        lat: arc.endLat,
        lng: arc.endLng,
        color: arc.color,
        ...ringDefaults
      }
    ])).flat();
    Globe.ringsData(gData)
      .ringColor('color')
      .ringMaxRadius('maxR')
      .ringPropagationSpeed('propagationSpeed')
      .ringRepeatPeriod('repeatPeriod')
      .ringResolution(64)

    const globeMaterial = Globe.globeMaterial();
    globeMaterial.color = new Color(0x3a228a);
    globeMaterial.emissive = new Color(0x220038);
    globeMaterial.emissiveIntensity = 0.3;
    globeMaterial.shininess = 0.7;



    // SCENE
    // Setup
    const scene = this.scene;
    scene.add(Globe);
    // Add lights & styling
    scene.add(new AmbientLight(0xbbbbbb, 0.7));
    scene.background = new Color(255, 255, 255) //(0x040d21);
    scene.fog = new Fog(0x535ef3, 400, 2000);

    // CAMERA
    // Setup
    const camera = this.camera;
    camera.aspect = width / height;

    // Lighting
    var dLight = new DirectionalLight(0xffffff, 0.8);
    dLight.position.set(-800, 2000, 400);
    camera.add(dLight);
    //
    var dLight1 = new DirectionalLight(0x7982f6, 1);
    dLight1.position.set(-200, 500, 200);
    camera.add(dLight1);
    //
    var dLight2 = new PointLight(0x8566cc, 0.5);
    dLight2.position.set(-200, 500, 200);
    camera.add(dLight2);

    // Position
    camera.position.z = 280;

    // Set camera to your location
    // Because it auto-rotates, we want to offset the camera a bit
    const latitude = myLat;
    const longitude = myLng + 30;
    // altitude in globe radius units
    let altitude = camera.position.z / Globe.getGlobeRadius();
    let { x, y } = Globe.getCoords(latitude, longitude, altitude);
    camera.position.x = x;
    camera.position.y = y;

    // Add to scene
    scene.add(camera);


    // CONTROLS
    const orbitControls = this.orbitControls;
    orbitControls.minPolarAngle = Math.PI / 4;
    orbitControls.maxPolarAngle = Math.PI - Math.PI / 3.5;
    orbitControls.enableDamping = true;
    orbitControls.dynamicDampingFactor = 0.01;
    orbitControls.enablePan = false;
    orbitControls.minDistance = 140;
    orbitControls.maxDistance = 300;
    orbitControls.rotateSpeed = 0.5;
    orbitControls.zoomSpeed = 0.2;
    orbitControls.autoRotate = true;
    orbitControls.autoRotateSpeed = 0.1;
    orbitControls.update();

    const animationFrame = 1;
    // START ANIMATION
    this.animate();
  }

  // ANIMATION
  // Render loop
  animate = () => {
    if (this.shouldAnimate) {
      requestAnimationFrame(this.animate);
      this.orbitControls.update();
      this.renderer.render(this.scene, this.camera);
    }
  };


}
