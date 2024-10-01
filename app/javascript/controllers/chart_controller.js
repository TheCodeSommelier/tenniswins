import { Controller } from "@hotwired/stimulus";
import { Chart } from "chart.js";

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    wonBets: Number,
    lostBets: Number
  };

  connect() {
    this.initializeChart();
  }

  initializeChart() {
    const wonBets = this.wonBetsValue;
    const lostBets = this.lostBetsValue;

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
          '#060701',
          ],
          borderColor: ['#C1E021', '#C1E021'],
          borderWidth: 2,
          hoverOffset: 4
        }]
      },
      options: {
        maintainAspectRatio: false,
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
        }
      },
    });
  }
}
