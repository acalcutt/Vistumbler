---
title: 'Flashing Tuya/Smart Life based RGBW bulbs to use in Home Assistant'
date: '08-12-2019 18:14'
visible: true
---

**References**

- [Tuya-Convert](https://github.com/ct-Open-Source/tuya-convert) (a script that allows you to update tuya devices firmware through wifi)
- [Kali Linux](https://www.kali.org/downloads/)<span> (a live cd/usb bootable linux that has all the tools we need. the tuya-convert scripts may work with other versions of linux, but they say they are made to work with kali linux)</span>
- [How to Configure Tasmota with Home Assistant - Auto Discovery and Legacy - Tasmota Tips Episode 2](https://www.youtube.com/watch?v=KOg5qwO3Rh4) ( A good guide on setting up MQTT in Homeassistant, and connecting tasmota to it)
- [Tasmota Device Templates Repository](https://blakadder.github.io/templates/) (a place to find user submitted configurations and check compatibility with tasmota for various tuya based devices)
 
Flashing the bulb with tasmota firmware
---------------------------------------

1. Boot into kali linux (I used '<span>kali-linux-2019.4-amd64.iso' on a Dell E6430 for this, which had a supported wireless card out of the box)</span>
2. <span>In kali, Connect to a wifi connection with internet access</span>
3. <span>Open a shell and download tuya-convert with the following commands</span>
1. <span>git clone https://github.com/ct-Open-Source/tuya-convert</span>
2. <span>cd tuya-convert</span>
3. <span>./install\_prereq.sh</span>
 
5. Disconnect from the wifi connection with internet
6. Update your bulbs firmware
1. <span>./start\_flash.sh</span>
2. The <span>script</span> requests that you connect something (anything) to the 'vtrust-flash' ap before starting the flash. I connected to this with my cell phone during the flash only.
3. <span>The <span>script</span> makes you put the bulb into fast blinking mode. In my bulbs case, this means your turn the light on and off 3 times, then it starts blinking.</span>
4. <span>The script asks what firmware you want, I selected '2.) flash tasmota'</span>
5. <span>The flash should tell you it has completed, read carefully in case there are some extra steps (mine did not have any but I read some devices do)</span>
 
8. Connect directly to the new bulb wifi access point, it should be called '<span>tasmota-xxxx'</span>
9. <span>Configure the bulbs wifi network, by going to <span>192.168.4.1 in your web browser.</span></span>
1. <span><span>In the bulb configuration, scan for your wifi network (don't type it in).</span></span>
2. <span><span>Make sure you get the password correct. I have not done it yet, but i read if you put wrong info here, you could be locked out of the device, so make sure it is right.</span></span>
3. <span><span>In the bottom field, give the device a easy to find name, since this should show up in your DHCP server when you look for it later.</span></span>
4. <span><span></span></span>After saving the settings, the device will restart and connect to the wifi network you set. You will no longer see the 'tasmota-xxxx' network.
 
11. <span>Find the new devices IP in your DHCP server. it should have whatever name you set in the previous step. You will then browse to this IP in your web browser</span>
12. <span>At the bulb config page, choose the 'Firmware Upgrade' button, set the OTA Url (I left this default), and click 'Start Upgrade'. The bulb will install a firmware update and reboot (takes about a minute)</span>
13. Once the bulb reboots, you can set its configuration options. A good place to look for a configuration is the '[Tasmota Device Templates Repository](https://blakadder.github.io/templates/)'. For my devices i did the following.
1. Go to 'Configuration --&gt; Configuration Other'
1. Set your device Template string, for my devices I used the fowllowing



- [LED Candelabra 4.5W](https://www.amazon.com/gp/product/B07TMW9XR7)
- {"NAME":"DOGAIN","GPIO":\[0,0,0,0,40,41,0,0,38,39,37,0,0\],"FLAG":0,"BASE":18}
 
- [OHLUX Smart WiFi LED Light Bulbs7W E26](https://www.amazon.com/gp/product/B07LCB3HQJ) and [Sinvitron Led Wifi Smart Light Bulb E26 9W](https://www.amazon.com/gp/product/B07RSRX1YR)
- {"NAME":"OHLUX","GPIO":\[0,0,0,0,37,40,0,0,38,41,39,0,0\],"FLAG":0,"BASE":18}
 
 
6. After settings up the configuration, you should now be able to control your light from the main page when you go to the lights IP. Verify the colors in the interface match what the light is showing, otherwise you may need to tweak your configuration at <span>'Configuration --&gt; Configuration Template'</span>
7. <span>You bulb is now flashed and ready to go, the next step will be to set up <span>'Configuration --&gt; Configuration MQTT', so it can be controlled by Home Assistant(Hass.io)</span></span>
<span><span>Set up bulb for Home Assistant Auto Discovery </span></span>
------------------------------------------------------------------------

1. On your Home Assistant Server, set up MQTT. I used this helpful youtube video ( [How to Configure Tasmota with Home Assistant - Auto Discovery and Legacy - Tasmota Tips Episode 2](https://www.youtube.com/watch?v=KOg5qwO3Rh4) )
1. Go to 'Hass.io', 'Add-on store' and install mosquitto broker
2. Under the <span>mosquitto broker page, set up the login information in the config, use the example shown here ( <https://www.home-assistant.io/addons/mosquitto/> )</span>
1. <span><span> </span><span class="token property">"logins"</span><span class="token operator">:</span><span> </span><span class="token punctuation">\[</span><span> </span><span class="token punctuation">{</span><span class="token property">"username"</span><span class="token operator">:</span><span> </span><span class="token string">"local-user"</span><span class="token punctuation">,</span><span> </span><span class="token property">"password"</span><span class="token operator">:</span><span> </span><span class="token string">"mypw"</span><span class="token punctuation">}</span><span> </span><span class="token punctuation">\]</span><span class="token punctuation">,</span></span>
2. <span><span class="token punctuation">Once this is set the <span>mosquitto add-on can be started.</span></span></span>
 
4. Configure Home Assistant to use the new MQTT broker just created
1. Go to 'Configuration -&gt; Integrations' and you should see a MQTT configure button.
2. Cleck 'Enable Discovery', then click submit.
 

3. Set up your bulb to connect to your new <span>Home Assistant Server </span>MQTT Broker
1. Go to your bulbs ip address in a browser.
2. <span>'Configuration --&gt; Configuration MQTT'</span>
1. Host \[Your MQTT Server, same as the Home Assitant server IP\]  
    Port \[1883\]  
    User \[Username set up in MQTT config\]  
    Password \[Username set up in MQTT config\]  
    Client and Topic can be left default, but I usually set them to something identifiable.
 
4. Go back to the main page and select console, and look for the following (If you do not see this, restart the light and look again)
1. 20:30:59 MQT: Attempting connection...  
    20:30:59 MQT: Connected
2. If you see connected, your MQTT is working
 
6. enable 'Home Assistant automatic discovery'
1. Go back to the bulb main page and select 'Console'
2. Enter '[SetOption19 1](https://github.com/arendst/Tasmota/wiki/Commands#setoption-overview)' and hit enter
3. <span><span>Home Assistant automatic discovery should now be enabled, you home assistant should now detect the new devices</span></span>

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'
 