ESP8266 Server Monitor
=========

A ESP8266-based standalone server monitor for the nodeMCU firmware.

![alt tag](https://raw.githubusercontent.com/th86/ESP8266ServerMonitor/master/img.png)

## Schematics ##

The the ESP8266 module used in this project is ESP03. The LDO for Vcc is an AMS1117, decoupled with two 22uF capacitors. AMS1117-3.3V is recommended. Connect 2 LEDs to GPIO12 (red) and GPIO14 (blue) as the server status indicators.

* CH_PD must be connected to Vcc.
* GPIO15 must be connected to GND.
* To flash the firmware, connect GPIO0 to GND before booting it. 

## Firmware ##
The firmware used in this project is nodemcu_512k_20141230.bin

## Operation ##
After setting up the SSID and the password of the AP in web.lua, please upload all three lua files to the ESP8266 module. 

When the module is connected to power, it enters the configuration mode for one minute, indicated by the glowing red LED. Please go to the IP of the module using a web browser to setup the IP of the server to be monitored and click submit.

Then the module goes to the monitoring mode. It checks the IP 35 every second. If the server runs normally, the blue LED glows. Otherwise, the red LED indicates that the remote IP does not respond to the request.

Copyright (c) 2015 Tai-Hsien Ouyang

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.