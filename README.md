# perfmeter

This repo contains powershell scripts to controll your arduino anaolog guage set.

![guages](guages.png)

You can run a demo by pasting the following command in your powershell terminal:

```iex (iwr https://raw.githubusercontent.com/zenvent/perfmeter/main/demo.ps1).Content```

You should see display like below, and you guage cluster come alive.
```{"gpu":1,"cpu":0,"ram":18,"net":0}```

If you get an error, cheeck for driver updates.
```Failed to connect to device.```

If the demo works, proceed with installing it as a service so that it's always running.
Performance should be neglegable as these metrics are already recorded by windows in the background.

// TODO
// Make a service
