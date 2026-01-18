---
title: 'Hass.io, recover config files from cli'
date: '07-01-2020 16:39'
visible: true
---

Source: <https://community.home-assistant.io/t/edit-configuration-yaml-with-hass-io-cli/100421/9>

1. `login` to get out of hassio cli and into bash
2. `docker ps` to get a list of containers
3. note the first 3 characters or so of the container for homeassistant - for me it was **51a**
4. `docker exec -it 51a /bin/bash`
5. `ls` to make sure configuration.yaml is there
6. `vi configuration.yaml` to edit the file
7. edit your mistake
8. esc + `:wq` to save and exit
9. `exit` then `login` to get back to hassio CLI
10. `homeassistant check` to make sure the conf is right this time
11. `homeassistant restart`

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'