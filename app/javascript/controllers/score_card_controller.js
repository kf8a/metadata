import { Controller } from "@hotwired/stimulus"
import { max, range, scaleLinear, scaleSqrt, select } from "d3"

// A datatable's score card: one circle per year with data, green by the share of
// records collected that year, blue where collected records still await release.
export default class extends Controller {
  static values = { scores: Array, firstYear: { type: Number, default: 1987 } }

  connect() {
    this.element.replaceChildren()
    if (this.scoresValue.length === 0) return

    const width = 800
    const radius = 14
    const currentYear = new Date().getFullYear()
    const x = scaleLinear()
      .domain([this.firstYearValue, currentYear])
      .range([radius, width - radius])
      .clamp(true)
    const color = scaleSqrt().domain([-1, 0, 1]).range(["blue", "white", "limegreen"])

    const maxCount = max(this.scoresValue, (d) => +d.count) || 1
    const scores = this.scoresValue.map((d) => {
      const count = +d.count
      const approved = d.approved === undefined ? undefined : +d.approved
      const score = count > approved ? (approved - count) / maxCount : count / maxCount
      return { year: +d.year, score }
    })

    const svg = select(this.element)
      .append("svg")
      .attr("class", "score")
      .attr("width", width)
      .attr("height", 2 * radius + 2)

    svg.selectAll("circle.dots")
      .data(range(this.firstYearValue + 1, currentYear))
      .join("circle")
      .attr("class", "dots")
      .attr("cx", (year) => x(year))
      .attr("cy", radius + 1)
      .attr("r", 2)
      .attr("fill", "grey")

    svg.selectAll("circle.circle")
      .data(scores)
      .join("circle")
      .attr("class", "circle")
      .attr("cx", (d) => x(d.year))
      .attr("cy", radius + 1)
      .attr("r", radius)
      .attr("stroke", "black")
      .attr("fill", (d) => color(d.score))
      .append("title")
      .text((d) => d.year)

    svg.selectAll("text.year")
      .data(scores)
      .join("text")
      .attr("class", "year")
      .attr("x", (d) => x(d.year))
      .attr("y", radius + 5)
      .attr("text-anchor", "middle")
      .attr("pointer-events", "none")
      .text((d) => String(d.year).slice(-2))
  }
}
