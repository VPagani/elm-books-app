import { Elm } from './Main.elm';
import './main.scss';

const app = Elm.Main.init({
    node: document.querySelector('#app'),
    flags: localStorage.data
});

app.ports.saveData.subscribe(data => localStorage.data = data)

window.addEventListener('storage', ev => {
    if (ev.key === "data")
        app.ports.updatedData.send(localStorage.data)
})

window.clear = () => app.ports.clear.send(null);
window.reset = () => app.ports.reset.send(null);