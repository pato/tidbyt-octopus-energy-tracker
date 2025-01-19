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

def format_two_decimals(value):
    # Round to 2 decimal places
    return str(math.round(value * 100) / 100)

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

    # Calculate today's and tomorrow's rates
    rate_today = prices[1]["value_inc_vat"]  # Second to last item is today
    rate_tomorrow = prices[0]["value_inc_vat"]  # Last item is tomorrow

    percent_change = format_percentage_change(rate_today, rate_tomorrow)

    # Compute the average price
    total_price = 0
    for _, value in data_points:
        total_price += value
    average_price = total_price / len(data_points)

    # Shift data points so the average price becomes 0
    shifted_data_points = [(day, value - average_price) for day, value in data_points]

    # Compute y-limits for the shifted data points
    y_min = shifted_data_points[0][1]
    y_max = shifted_data_points[0][1]
    for _, value in shifted_data_points:
        if value < y_min:
            y_min = value
        if value > y_max:
            y_max = value

    return render.Root(
        child = render.Box(
            render.Column(
                children=[
                    render.Row(
                        expanded=True, # Use as much horizontal space as possible
                        main_align="space_evenly", # Controls horizontal alignment
                        cross_align="center", # Controls vertical alignment
                        children = [
                            # render.Text(content=("%s" % format_two_decimals(rate_today)), color="#F050F8"),
                            render.Text(content=("%s" % format_two_decimals(rate_today))),
                            # render.Text(content=("%s" % format_two_decimals(rate_tomorrow)), color="#B6B2DF"),
                            render.Text(content=("%s" % format_two_decimals(rate_tomorrow)), color="#9897A9"),
                        ],
                    ),
                    render.Row(
                        expanded=True, # Use as much horizontal space as possible
                        main_align="space_evenly", # Controls horizontal alignment
                        cross_align="center", # Controls vertical alignment
                        children = [
                            render.Text(content=("avg: %s" % format_two_decimals(average_price)), color="#099", font="CG-pixel-4x5-mono"),
                        ],
                    ),
                    render.Plot(
                        data=shifted_data_points,
                        width=64,
                        height=16,
                        color="#f00",
                        color_inverted="#0f0",
                        x_lim=(0, len(shifted_data_points) - 1),
                        y_lim=(y_min - 1, y_max + 1),  # Padding added to y-limits
                        fill=True,
                    ),
                ],
            )
        )
    )
