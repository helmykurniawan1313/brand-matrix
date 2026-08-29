// Tree-shaken Chart.js registration, shared by every page/component that renders
// a chart — replaces `chart.js/auto` (which registers every controller, scale,
// and plugin Chart.js ships) with only what this app actually uses: line, bar,
// and pie charts, category/linear scales, the Filler plugin (for line-chart area
// fills), plus tooltip/legend. Cuts each chart-bearing page's bundle chunk down
// from the full ~200KB Chart.js build to only the pieces in use.
import {
    Chart,
    LineController,
    BarController,
    PieController,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    ArcElement,
    Filler,
    Tooltip,
    Legend,
} from 'chart.js';

Chart.register(
    LineController,
    BarController,
    PieController,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    ArcElement,
    Filler,
    Tooltip,
    Legend,
);

export { Chart };
export default Chart;
