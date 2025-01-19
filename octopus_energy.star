load("render.star", "render")
load("http.star", "http")
load("time.star", "time")
load("math.star", "math")

def format_percentage_change(rate_today, rate_tomorrow):
    percentage_change = int(math.round(((rate_tomorrow - rate_today) / rate_today) * 100))
    if percentage_change >= 0:
        return "+" + str(percentage_change) + "%"
    else:
        return str(percentage_change) + "%"

def main(config):
    timezone = config.get("timezone") or "Europe/London"
    now = time.now().in_location(timezone)
    tomorrow = now + (time.hour * 24 * 2)
    start = now - (time.hour * 24 * 7)

    product = "SILVER-BB-23-12-06"
    tariff = "E-FLAT2R-SILVER-BB-23-12-06-C"
    period_from = start.format("2006-01-02T00:00Z")
    period_to = tomorrow.format("2006-01-02T00:00Z")

    price_url = "https://api.octopus.energy/v1/products/{}/electricity-tariffs/{}/day-unit-rates/?period_from={}&period_to={}".format(product, tariff, period_from, period_to)
    print("price_url", price_url)

    rep = http.get(price_url)
    if rep.status_code != 200:
        fail("Octopus request failed with status %d", rep.status_code)

    # check the valid_from/valid_to and see if we have the price for tomorrow already

    rate_today = rep.json()["results"][1]["value_inc_vat"]
    rate_tomorrow = rep.json()["results"][0]["value_inc_vat"]

    percent_change = format_percentage_change(rate_today, rate_tomorrow)
    print("change", percent_change)
    print("rate_today", rate_today)
    print("rate_tomorrow", rate_tomorrow)

    return render.Root(
        render.Column(
            children=[
                render.Text("%s" % rate_today),
                render.Text("%s %s" % (rate_tomorrow, percent_change)),
                render.Plot(
                    data = [
                        (0, 3.35),
                        (1, 2.15),
                        (2, 2.37),
                        (3, -0.31),
                        (4, -3.53),
                        (5, 1.31),
                        (6, -1.3),
                        (7, 4.60),
                        (8, 3.33),
                        (9, 5.92),
                        ],
                    width = 64,
                    height = 16,
                    # color = "#0f0",
                    # color_inverted = "#f00",
                    color = "#f00",
                    color_inverted = "#0f0",
                    x_lim = (0, 9),
                    y_lim = (-5, 7),
                    fill = True,
                    ),
            ],
        )
    )
