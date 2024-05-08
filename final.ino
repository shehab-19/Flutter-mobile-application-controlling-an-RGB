#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char* ssid = "Link111";
const char* password = "qazwsxedc";
const int redPin = D5;
const int greenPin = D6;
const int bluePin = D7;

ESP8266WebServer server(80);

void handleDataRequest() {
  String color = server.arg("color");
  String brightnessStr = server.arg("brightness");
  float brightness = brightnessStr.toFloat();

  if (color.equals("RED")) {
    analogWrite(redPin, 255 * brightness);
    analogWrite(greenPin, 0);
    analogWrite(bluePin, 0);
  } else if (color.equals("GREEN")) {
    analogWrite(redPin, 0);
    analogWrite(greenPin, 255 * brightness);
    analogWrite(bluePin, 0);
  } else if (color.equals("BLUE")) {
    analogWrite(redPin, 0);
    analogWrite(greenPin, 0);
    analogWrite(bluePin, 255 * brightness);
  } else if (color.equals("OFF")) {
    analogWrite(redPin, 0);
    analogWrite(greenPin, 0);
    analogWrite(bluePin, 0);
  }

  server.send(200, "text/plain", "Data received and processed successfully");
}

void setup() {
  Serial.begin(9600);

  // Connect to Wi-Fi
  Serial.printf("Connecting to Wi-Fi network: %s\n", ssid);
  WiFi.begin(ssid, password);

  // Wait for Wi-Fi connection
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
    attempts++;
    
    if (attempts > 20) {
      Serial.println("\nFailed to connect to Wi-Fi. Check credentials.");
      return;
    }
  }

  // Wi-Fi connected
  Serial.println("\nConnected to Wi-Fi!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Setup HTTP server routes
  server.on("/data", HTTP_GET, handleDataRequest);
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}
