

function wifi_config()
    print("smart")
    wifi.setmode(wifi.STATIONAP)

    station_cfg={}
    station_cfg.ssid=nil
    station_cfg.pwd=nil

    cfg={}
    cfg.ssid="MyClock-"..node.chipid()
    cfg.pwd="12345678"

    -- read AP config
    if file.exists("device.config") then
        print("Config file exists")
        if file.open("device.config", "r") then
            -- AP ssid
            APSSID=file.read("\r")
            file.read("\n")
            -- AP PWD
            APPWD=file.read("\r")
            file.read("\n")
            -- pwd
            PWD=file.read("\r")
            file.close()
            if PWD=='\r' or PWD==nil then
                print("password is emtpy")
                cfg.pwd=nil
            else
                cfg.pwd=string.sub(PWD,1,string.len( PWD )-1)
            end

            print(cfg.ssid)
            print(cfg.pwd)


            if(APPWD=='\r' or APPWD==nil) then
                print("AP PWD is nil")
                station_cfg.pwd=nil
            else
                APPWD=string.sub(APPWD,1,string.len( APPWD )-1)
                print("AP PWD:"..APPWD)
                station_cfg.pwd=APPWD
            end
            
            if(APSSID=='\r' or APSSID==nil) then
                print("AP is nil")
            else
                APSSID=string.sub(APSSID,1,string.len( APSSID )-1)
                print("AP:"..APSSID)
                station_cfg.ssid=APSSID
                wifi.sta.config(station_cfg)
                wifi.sta.autoconnect(1)
            end
        end
    end
    wifi.ap.config(cfg)
end
