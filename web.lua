--ESP8266-based Server Monitor, Tai-Hsien Ouyang, 2015
wifi.setmode(wifi.STATION)
wifi.sta.config("MY_SSID","MY_PASSWORD")
print(wifi.sta.getip())
gpio.INPUT=0;
LED_1=5; --GPIO14
LED_2=6; --GPIO12
is_on=1; --GPIO16
gpio.mode(LED_1, gpio.OUTPUT);gpio.mode(LED_2, gpio.OUTPUT);gpio.mode(is_on, gpio.INPUT);
gpio.write(LED_1, gpio.LOW);gpio.write(LED_2, gpio.LOW);
function setting_HTTP(server_IP)
    gpio.write(LED_1, gpio.LOW);
    gpio.write(LED_2, gpio.HIGH);
    server=net.createServer(net.TCP);
    server:listen(80,function(conn)
    conn:on("receive",function(client,request)
    local buf = "";
    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end 
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end   
        end     
     if _GET.IP then
            IP_record='IP='..'"'.._GET.IP..'"';
            print(IP_record);
            file.open("settings.lua","w+");
            file.writeline(IP_record);
            file.close();
    end
    buf = buf.."HTTP/1.1 200 OK\n\n";
    buf = buf.."<html><head></head><body><h1>Portable Network Service Monitor</h1>";
    buf = buf.."<p>Node's IP "..wifi.sta.getip().."</p>";
    buf = buf.."<form action=\"\" method=\"POST\">";
    buf = buf.."Target Server's IP <input type=\"text\" name=\"IP\">";
    buf = buf.."<input type=\"submit\" value=\"Submit\">";
    buf = buf.."<p>Tai-Hsien Ouyang, 2015<\p></form></body></html>";
    client:send(buf);
    client:close();
    collectgarbage();
    end)
    end)
end
function poke_server()
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
poker:connect(80,server_IP);
is_on=tonumber(gpio.read(is_on));
end
tmr.alarm(0,5000,0,function() poke_server(IP_record) end);
setting_HTTP();
require("settings")
print(IP_record)
tmr.alarm(0,60000,1,function() poke_server(IP_record) end); --60sec
