import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    wonBets: Number,
    lostBets: Number,
    moneyMade: String
  };

  connect() {
    this.initializeChart();
  }

  initializeChart() {
    const wonBets = this.wonBetsValue;
    const lostBets = this.lostBetsValue;
    const moneyMade = this.moneyMadeValue;

    const ctx = document.getElementById('betsPieChart').getContext('2d');
    new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Won', 'Lost'],
        datasets: [{
          label: 'Bets',
          data: [wonBets, lostBets],
          backgroundColor: [
          '#C1E021',
          '#060701'
          ],
          borderColor: ['#C1E021', '#C1E021'],
          borderWidth: 2,
          hoverOffset: 4
        }]
      },
      options: {
        plugins: {
          legend: {
            labels: {
              color: '#f7f8f1',
              font: {
                size: 18,
              },
              usePointStyle: true,
              pointStyle: 'rectRounded'
            }
          },
          centerText: {
            display: true,
            text: `$${moneyMade}`
          }
        }
      },
      plugins: [this.#createCenterTextPlugin()]
    });
  }

  #createCenterTextPlugin() {
    return {
      id: 'centerText',
      beforeDraw(chart) {
        if (chart.config.options.plugins.centerText.display !== null &&
            typeof chart.config.options.plugins.centerText.display !== 'undefined' &&
            chart.config.options.plugins.centerText.display) {
          const ctx = chart.ctx;
          const centerText = chart.config.options.plugins.centerText.text;
          const width = chart.width;
          const height = chart.height;
          ctx.restore();
          const fontSize = (height / 114).toFixed(2);
          ctx.font = `${fontSize}em sans-serif`;
          ctx.textBaseline = "middle";
          ctx.fillStyle = "#C1E021";

          const textX = Math.round((width - ctx.measureText(centerText).width) / 2);
          const textY = height / 2 + 20;

          ctx.fillText(centerText, textX, textY);
          ctx.save();
        }
      }
    };
  }
}
