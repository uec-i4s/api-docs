import SwaggerUI from "swagger-ui";
import SwaggerUIStandalonePreset from "swagger-ui/dist/swagger-ui-standalone-preset";
import "swagger-ui/dist/swagger-ui.css";

SwaggerUI({
  urls: [
    { url: "./specs/aia-v1.yaml", name: "AIA v1" },
    { url: "./specs/patlite-v1.yaml", name: "Patlite v1" },
  ],
  dom_id: "#app",
  deepLinking: true,
  presets: [SwaggerUI.presets.apis, SwaggerUIStandalonePreset],
  layout: "StandaloneLayout",
});
