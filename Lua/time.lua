-- NTP server list
hosts={"s1a.time.edu.cn", "sgp.ntp.org.cn","stdtime.gov.hk"}
num=table.getn(hosts)

local hour=0
local min=0
local dm=0
local dh=0
local cnt=0


function sync()
    print("sync")
    local i=1
    sntp.sync(hosts[1],
        function(sec, usec, server, info)
            rtctime.set(sec + 28801)
            print('sync', sec, usec, server)
            tmr.stop(3)
            tmr.stop(2)
            duty6=pwm.getduty(6)
            duty5=pwm.getduty(5)
            cnt=11
            tm = rtctime.epoch2cal(rtctime.get())

            tmp=tm["hour"];
    
            if(tmp>12) then
                tmp=tmp-12
            end

            hour=(101000-(tmp*10)*733)/100
            min = (tm["min"]*1333)/100
            dm=(duty5-min)
            dh=(duty6-hour)
            print(dh..","..dm)
            tmr.start(4)
            
            --sync(1)
        end,
        function(n,e)
			
            print('failed! ')
            if(n~=nil) then print(n) end
			if(e~=nil) then print(e) end
            local tmp=hosts[1]
            while(i<num)
            do
                hosts[i]=hosts[i+1]
                i=i+1;
            end
            hosts[num]=tmp
            table.foreach(hosts, function(i, v) print (i, v) end)
            tmr.start(3)

        end,
        1
    )

end



function run()
    tm = rtctime.epoch2cal(rtctime.get())

    tmp=tm["hour"];
    
    if(tmp>12) then
        tmp=tmp-12
    end

    hour=(101000-(tmp*10)*733)/100
    min = (tm["min"]*1333)/100
    pwm.setduty(6,hour)
    pwm.setduty(5,min)
end

function goto()
    duty5=(duty5*10-dm)/10
    duty6=(duty6*10-dh)/10
    pwm.setduty(6,duty6)
    pwm.setduty(5,duty5)
end

tmr.register(4, 50, tmr.ALARM_AUTO, function()
    cnt=cnt-1
    if(cnt==0) then
        tmr.stop(4)
        tmr.start(1)
    end
    goto()
end)
