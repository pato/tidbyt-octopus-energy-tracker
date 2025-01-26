# Octopus Energy Price Tracker for Tidbyt

A simple Octopus Energy Flexible Tariff tracker for Tidbyt.

![Image](https://plankenau.com/i/8F0IuIuwNKYQB.png "octopus energy monitor")

## Features

This app displays:
- Today's electricity price (in pence per kilowatt hour)
- Tomorrow's electricity price
- The average price over the last 30 days
- A graph of electricity prices over the last 30 days (compared to the average
  price)

## Requirements

- The [`pixlet`][pixlet] toolkit provided by Tidbyt
- Your Octopus energy tariff identifier

## Rendering and deploying

You can render it locally using

```shell
pixlet render octopus_energy.star
```

You can also render+deploy it to your local Tidbyt using

```shell
pixlet render octopus_energy.star && pixlet push ${YOUR_TIDBYT_ID} octopus_energy.webp -installation-id octopusenergy
```

## Running it continually

![Image](https://plankenau.com/i/HxffN6Nwy4MIK.jpg "real octopus energy monitor")

You can read about how I used a Synology NAS to continually deploy it with the
latest information to my Tidbyt over at [my blog][blogpost].

[pixlet]: https://github.com/tidbyt/pixlet
[blogpost]: https://plankenau.com/blog/post/tidbyt-octopus-energy-tracker
