document.addEventListener("DOMContentLoaded", function () {
  const p = document.createElement("p");
  p.innerHTML = "Text added by javascript";

  document.getElementsByTagName("body")[0].appendChild(p);
});
