require "time"
require "smart"


function startup()
print("start")

-- GPIO5 Minute PWM 0-800
-- GPIO6 Hour   PWM 1010-130

pwm.stop(5)
pwm.close(5)
pwm.setup(5, 500, 0)
pwm.start(5)
pwm.stop(6)
pwm.close(6)
pwm.setup(6, 500, 1010)
pwm.start(6)

tmr.start(2)

wifi_config()

dofile("httpServer.lua")
httpServer:listen(80)

httpServer:use("/confirm", function(req, res)
        print(req.query.ssid)
        print(req.query.pwd)
        print(req.query.mngpwd)

        if(req.query.ssid==nil) then
            --change pwd
            if file.open("device.config", "r") then
                -- AP ssid
                APSSID=file.read("\r")
                file.read("\n")
                -- AP PWD
                APPWD=file.read("\r")

                file.close()
            else
                print("device.config no exist")
                APSSID=''
                APPWD=''
            end

            if file.open("device.config", "w") then
                if(APSSID==nil or APSSID=='\r') then
                    print("APSSID is nil")
                    APSSID=''
                end

                if(APPWD==nil or APPWD=='\r') then
                    print("APPWD is nil")
                    APPWD=''
                end

                PWD=req.query.mngpwd

                file.write(APSSID.."\r\n")
                file.write(APPWD.."\r\n")
                file.write(PWD.."\r\n")
                file.close()
                res:sendFile('sucess.html')
            else
                res:sendFile('failed.html')
            end
        else
            --change AP
            if file.open("device.config", "r") then
                -- AP ssid
                APSSID=file.read("\r")
                file.read("\n")
                -- AP PWD
                APPWD=file.read("\r")
                file.read("\n")
                -- PWD
                PWD=file.read("\r")
                file.close()
            else
                print("device.config no exist")
                PWD=''
            end

            if file.open("device.config", "w") then

                APSSID=req.query.ssid
                APPWD=req.query.pwd

                if(APSSID==nil or APSSID=='\r') then
                    print("APSSID is nil")
                    APSSID=''
                end

                if(APPWD==nil or APPWD=='\r') then
                    print("APPWD is nil")
                    APPWD=''
                end

                file.write(APSSID.."\r\n")
                file.write(APPWD.."\r\n")
                file.write(PWD.."\r\n")
                file.close()
                res:sendFile('sucess.html')
            else
                res:sendFile('failed.html')
            end

        end
    end
    )

end


-- start
node.setcpufreq(node.CPU80MHZ)
print("wait 3s")

local i=0
local flag=0

pwm.stop(5)
pwm.close(5)
pwm.setup(5, 500, 0)
pwm.start(5)
pwm.stop(6)
pwm.close(6)
pwm.setup(6, 500, 1010)
pwm.start(6)

wifi.setmode(wifi.NULLMODE)

-- WIFI state Monitor
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
		print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
		wifi_con=true
	end
)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(T)
		print("WIFI down")
		wifi_con=false
        tmr.stop(1)
        tmr.start(2)  
	end
)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 sync()
 end)

tmr.alarm(0,500,0,startup)

-- time
tmr.register(1, 1000, tmr.ALARM_AUTO, run)

-- wave
tmr.register(2, 20, tmr.ALARM_AUTO, function()
    pwm.setduty(5,i)
    pwm.setduty(6,(10100-11*i)/10)
    if(flag==0) then
        if(i<800) then
            i=i+15
        else
            flag=1
        end
    else
        if(i>0) then
            i=i-15
        else
            flag=0
        end
    end 
end)

tmr.register(3, 3000, tmr.ALARM_SEMI, function() sync() end)

