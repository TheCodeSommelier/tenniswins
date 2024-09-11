export default class FormUtils {
  buildInput(options = {}) {
    const input = document.createElement("input");

    if (options.type) input.setAttribute("type", options.type);
    if (options.step) input.setAttribute("step", options.step);
    if (options.name) input.setAttribute("name", options.name);
    if (options.id) input.setAttribute("id", options.id);
    if (options.value) input.value = options.value;
    if (options.placeholder)
      input.setAttribute("placeholder", options.placeholder);
    if (options.classes)
      options.classes.forEach((className) => input.classList.add(className));
    if (options.data) this.#createDataAttrs(options.data, input);

    return input;
  }

  buildLabel(options = {}) {
    const label = document.createElement("label");

    if (options.for) label.setAttribute("for", options.for);
    if (options.classes)
      options.classes.forEach((className) => label.classList.add(className));

    return label;
  }

  buildUl(options = {}) {
    const ul = document.createElement("ul");

    if (options.classes)
      options.classes.forEach((className) => ul.classList.add(className));
    if (options.data) this.#createDataAttrs(options.data, ul);

    return ul;
  }

  buildButton(options) {
    const button = document.createElement("button");

    if (options.classes)
      options.classes.forEach((className) => button.classList.add(className));
    if (options.data) this.#createDataAttrs(options.data, button);
    if (options.id) button.setAttribute("id", options.id);
    if (options.type) button.setAttribute("type", options.type);
    if (options.text) button.innerText = options.text;

    return button;
  }

  #createDataAttrs(data, element) {
    if (typeof data === "object" && data !== null) {
      Object.keys(data).forEach((key) => {
        element.dataset[key] = data[key];
      });
    }
  }
}
