import SwaggerUI from "swagger-ui";
import SwaggerUIStandalonePreset from "swagger-ui/dist/swagger-ui-standalone-preset";
import "swagger-ui/dist/swagger-ui.css";

SwaggerUI({
  urls: [
    { url: "./specs/aia-v1.yaml", name: "AIA v1" },
    { url: "./specs/aia-v2.yaml", name: "AIA v2" },
    { url: "./specs/e36-v1.yaml", name: "E36 v1" },
    { url: "./specs/omron-v1.yaml", name: "OMRON v1" },
    { url: "./specs/patlite-v1.yaml", name: "Patlite v1" },
    { url: "./specs/w9-v1.yaml", name: "W9 v1" },
    { url: "http://openapi.i4s.uec.ac.jp/docs/actuator/w9_elevator/openapi.json", name: "W9 Elevator v1" },
  ],
  dom_id: "#app",
  deepLinking: true,
  presets: [SwaggerUI.presets.apis, SwaggerUIStandalonePreset],
  layout: "StandaloneLayout",
});
