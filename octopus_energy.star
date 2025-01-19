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
    start = now - (time.hour * 24 * 30)

    product = "SILVER-BB-23-12-06"
    tariff = "E-FLAT2R-SILVER-BB-23-12-06-C"
    period_from = start.format("2006-01-02T00:00Z")
    period_to = tomorrow.format("2006-01-02T00:00Z")

    price_url = "https://api.octopus.energy/v1/products/{}/electricity-tariffs/{}/day-unit-rates/?period_from={}&period_to={}".format(product, tariff, period_from, period_to)
    print("price_url", price_url)

    rep = http.get(price_url)
    if rep.status_code != 200:
        fail("Octopus request failed with status %d", rep.status_code)

    # Parse the response to extract prices and dates
    prices = rep.json()["results"]
    data_points = []

    for idx, price in enumerate(reversed(prices)):  # Reverse to order by time
        day = idx
        value = price["value_inc_vat"]
        data_points.append((day, value))

    print(prices)

    # Calculate today's and tomorrow's rates
    rate_today = prices[1]["value_inc_vat"]  # Second to last item is today
    rate_tomorrow = prices[0]["value_inc_vat"]  # Last item is tomorrow

    percent_change = format_percentage_change(rate_today, rate_tomorrow)
    print("change", percent_change)
    print("rate_today", rate_today)
    print("rate_tomorrow", rate_tomorrow)

    # Compute y-limits manually
    y_min = data_points[0][1]
    y_max = data_points[0][1]
    for _, value in data_points:
        if value < y_min:
            y_min = value
        if value > y_max:
            y_max = value

    return render.Root(
        render.Column(
            children=[
                render.Text("%s" % rate_today),
                render.Text("%s (%s)" % (rate_tomorrow, percent_change)),
                render.Plot(
                    data=data_points,
                    width=64,
                    height=16,
                    color="#f00",
                    color_inverted="#0f0",
                    x_lim=(0, len(data_points) - 1),
                    y_lim=(y_min - 1, y_max + 1),  # Padding added to y-limits
                    fill=True,
                ),
            ],
        )
    )
