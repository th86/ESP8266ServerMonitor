--ESP8266-based Server Monitor, Tai-Hsien Ouyang, 2015
wifi.setmode(wifi.STATION)
wifi.sta.config("MY_SSID","MY_PASSWORD")
LED_1=5; --GPIO14
LED_2=6; --GPIO12
gpio.mode(LED_1, gpio.OUTPUT);gpio.mode(LED_2, gpio.OUTPUT);
gpio.write(LED_1, gpio.LOW);gpio.write(LED_2, gpio.LOW);
require("settings");
function setting_HTTP()
    print(wifi.sta.getip());
    print("Setting mode");
    gpio.write(LED_1, gpio.LOW);gpio.write(LED_2, gpio.HIGH);
    srv=net.createServer(net.TCP);
    srv:listen(80,function(conn)
        conn:on("receive",function(client,request)
        local buf = "";
        parsePost={string.find(request,"IP=")};
        buf = buf.."HTTP/1.1 200 OK\n\n";
        buf = buf.."<html><head></head><body><h1>Portable Network Service Monitor</h1>";
        buf = buf.."<p>Node's IP "..wifi.sta.getip().."</p>";
        buf = buf.."<form action=\"\" method=\"POST\">";
        buf = buf.."<p>Now monitoring "..IP_record.."</p>";
        buf = buf.."Update the target IP <input type=\"text\" name=\"IP\">";
        buf = buf.."<input type=\"submit\" value=\"Submit\">";
        buf = buf.."<p>Tai-Hsien Ouyang, 2015</p></form></body></html>";
        if parsePost[2]~=nil then
            IP_record_print='IP_record='..'"'..string.sub(request,parsePost[2]+1,#request)..'"';
            IP_record=string.sub(request,parsePost[2]+1,#request)
            print(IP_record_print);
            file.open("settings.lua","w+");
            file.writeline(IP_record_print);
            file.close();
        end
        client:send(buf);
        client:close();
        collectgarbage();
        end)
    end)
    tmr.alarm(0,29000,0,function() print("Closing settings server..."); srv:close(); end);
end
function poke_server()
    print("poking mode:"..IP_record);
    gpio.write(LED_1, gpio.LOW);
    gpio.write(LED_2, gpio.LOW);
    poker= nil;
    poker=net.createConnection(net.TCP, 0);
    poker:on("receive", function(poker, payload)
    if (string.find(payload, "200 OK") == nil) then
        gpio.write(LED_1, gpio.LOW);
        gpio.write(LED_2, gpio.HIGH);
        print("server is DOWN");
    else
        gpio.write(LED_1, gpio.HIGH);
        gpio.write(LED_2, gpio.LOW);
        print("server is alive");
    end
    end)
    poker:on("connection", function(poker, payload)
        print ("poking...");
        poker:send("GET /index.html HTTP/1.1\r\nHost:"..wifi.sta.getip().."\r\n"
        .."Connection: close\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n");
    end)
    poker:on("disconnection", function(poker, payload)
        poker:close();
        collectgarbage();
    end)
    poker:connect(80, IP_record);
end

setting_HTTP();
print(IP_record);
tmr.alarm(1,35000,1,function() poke_server() end);
