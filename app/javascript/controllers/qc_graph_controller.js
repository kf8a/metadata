import { Controller } from "@hotwired/stimulus"
import {
  axisBottom, axisLeft, axisTop, area, extent, format, max, min, pointer,
  scaleLinear, scalePoint, scaleSqrt, scaleTime, select, timeFormat, timeParse,
} from "d3"

const parseDatetime = timeParse("%Y-%m-%d %H:%M:%S")
const toDate = (value) => parseDatetime(value) ?? new Date(value)
const humanNumber = format(",.2~f")
const shortDate = timeFormat("%Y-%m-%d")
const BLUE = "rgb(121,173,210)"
const YELLOW = "rgb(250,230,5)"

// QC graphs on a datatable's QC page: fetches a visualization's rows as JSON
// ({datetime, value} or {category, year|treatment, value}) and draws its graph type.
export default class extends Controller {
  static values = { url: String, type: String, yLabel: String }

  async connect() {
    this.element.replaceChildren()
    const response = await fetch(this.urlValue, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const rows = await response.json()
    if (!Array.isArray(rows) || rows.length === 0) return

    const draw = {
      "dot-graph": () => this.timeSeries(rows, { width: 660, mark: "dot" }),
      "area-graph": () => this.timeSeries(rows, { width: 360, mark: "area" }),
      "bar-graph": () => this.timeSeries(rows, { width: 360, mark: "bar" }),
      "bubble-graph": () => this.bubbles(rows, { across: "year", label: (d) => `${d.year}: ${humanNumber(d.value)}` }),
      "category-bubble-graph": () => this.bubbles(rows, { across: "treatment", label: (d) => `${humanNumber(d.value)} g/m2` }),
    }[this.typeValue]
    draw?.()
  }

  // Values over time as dots, an area or bars
  timeSeries(rows, { width, mark }) {
    const height = 260
    const margin = 40
    const data = rows
      .map((d) => ({ date: toDate(d.datetime), value: +d.value }))
      .filter((d) => !Number.isNaN(d.date.getTime()) && Number.isFinite(d.value))
      .sort((a, b) => a.date - b.date)
    if (data.length === 0) return

    const values = extent(data, (d) => d.value)
    const x = scaleTime().domain(extent(data, (d) => d.date)).range([0, width])
    const y = scaleLinear()
      .domain(mark === "dot" ? values : [Math.min(0, values[0]), values[1]])
      .nice()
      .range([height, 0])

    const plot = this.plot(width, height, { top: margin, right: margin, bottom: margin, left: margin })
    this.grid(plot, axisLeft(y).tickSize(-width), axisBottom(x).ticks(width / 80).tickSize(-height), height)
    this.yLabel(plot, height, margin)

    if (mark === "area") {
      plot.append("path")
        .datum(data)
        .attr("fill", BLUE)
        .attr("d", area().x((d) => x(d.date)).y0(y(Math.max(0, y.domain()[0]))).y1((d) => y(d.value)))
    } else if (mark === "bar") {
      plot.selectAll("rect.bar")
        .data(data)
        .join("rect")
        .attr("class", "bar")
        .attr("x", (d) => x(d.date) - 1.5)
        .attr("width", 3)
        .attr("y", (d) => Math.min(y(d.value), y(0)))
        .attr("height", (d) => Math.abs(y(0) - y(d.value)))
        .attr("fill", "steelblue")
    } else {
      plot.selectAll("circle.dot")
        .data(data)
        .join("circle")
        .attr("class", "dot")
        .attr("cx", (d) => x(d.date))
        .attr("cy", (d) => y(d.value))
        .attr("r", 2)
        .attr("fill", "rgba(121,172,210,0.4)")
      this.hover(plot, data, width, height, {
        position: (d) => [x(d.date), y(d.value)],
        label: (d) => `${humanNumber(d.value)} ${shortDate(d.date)}`,
      })
    }
  }

  // Bubbles sized by value: categories down the side, years or treatments across
  bubbles(rows, { across, label }) {
    const data = rows
      .map((d) => ({ ...d, value: +d.value, year: d.year === undefined ? undefined : +d.year }))
      .filter((d) => Number.isFinite(d.value))
    const categories = [...new Set(data.map((d) => d.category))].sort().reverse()
    const width = 400
    const height = Math.max(categories.length * 14, 14)
    const margin = { top: across === "year" ? 20 : 150, right: 50, bottom: 20, left: 380 }

    const y = scalePoint().domain(categories).range([height, 0]).padding(0.5)
    const x = across === "year"
      ? scaleLinear().domain([min(data, (d) => d.year), max(data, (d) => d.year)]).range([0, width])
      : scalePoint().domain([...new Set(data.map((d) => d.treatment))].sort().reverse()).range([0, width]).padding(0.5)
    const radius = scaleSqrt().domain([0, max(data, (d) => d.value) || 1]).range([0, Math.sqrt(500)])
    const xOf = (d) => x(d[across])

    const plot = this.plot(width, height, margin)
    plot.append("g")
      .attr("class", "categories")
      .call(axisLeft(y).tickSize(-width).tickPadding(20))
      .call((axis) => axis.selectAll("text").style("font-size", "10pt"))
      .call((axis) => this.styleAxis(axis))

    if (across === "year") {
      plot.append("g").call(axisTop(x).tickFormat(format("d")).tickSize(-height)).call((axis) => this.styleAxis(axis))
      plot.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(axisBottom(x).tickFormat(format("d")).tickSize(0))
        .call((axis) => axis.select(".domain").remove())
    } else {
      plot.append("g")
        .call(axisTop(x).tickSize(-height))
        .call((axis) => this.styleAxis(axis))
        .call((axis) => axis.selectAll("text")
          .attr("text-anchor", "start")
          .attr("transform", "rotate(-73)")
          .attr("dx", "0.5em"))
    }

    plot.selectAll("circle.bubble")
      .data(data)
      .join("circle")
      .attr("class", "bubble")
      .attr("cx", xOf)
      .attr("cy", (d) => y(d.category))
      .attr("r", (d) => radius(d.value))
      .attr("fill", "rgba(250,230,5,0.2)")
      .attr("stroke", "rgba(0,0,255,0.2)")

    this.hover(plot, data, width, height, { position: (d) => [xOf(d), y(d.category)], label })
  }

  plot(width, height, margin) {
    return select(this.element)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`)
  }

  grid(plot, yAxis, xAxis, height) {
    plot.append("g").call(yAxis).call((axis) => this.styleAxis(axis))
    plot.append("g").attr("transform", `translate(0,${height})`).call(xAxis).call((axis) => this.styleAxis(axis))
  }

  styleAxis(axis) {
    axis.select(".domain").remove()
    axis.selectAll(".tick line").attr("stroke", "#eee")
  }

  yLabel(plot, height, margin) {
    if (!this.yLabelValue) return

    plot.append("text")
      .attr("transform", `translate(${10 - margin},${height / 2}) rotate(-90)`)
      .attr("text-anchor", "middle")
      .text(this.yLabelValue)
  }

  // Highlights the point nearest the pointer and labels it
  hover(plot, data, width, height, { position, label }) {
    const marker = plot.append("circle").attr("r", 3).attr("fill", YELLOW).attr("stroke", "black").style("display", "none")
    const text = plot.append("text").attr("text-anchor", "middle").style("display", "none")

    plot.append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("fill", "transparent")
      .on("pointermove", (event) => {
        const [px, py] = pointer(event)
        let nearest
        let best = Infinity
        for (const d of data) {
          const [dx, dy] = position(d)
          const distance = (dx - px) ** 2 + (dy - py) ** 2
          if (distance < best) [best, nearest] = [distance, d]
        }
        const [nx, ny] = position(nearest)
        marker.attr("cx", nx).attr("cy", ny).style("display", null)
        text.attr("x", Math.min(Math.max(nx, 60), width - 60)).attr("y", ny - 8).text(label(nearest)).style("display", null)
      })
      .on("pointerleave", () => {
        marker.style("display", "none")
        text.style("display", "none")
      })
  }
}
