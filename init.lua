--ESP8266-based Server Monitor, Tai-Hsien Ouyang, 2015
function sysinit()
    print('Initializing...')
    dofile('web.lua')
    end
tmr.alarm(0,16000,0,sysinit)

