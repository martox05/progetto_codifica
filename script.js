/* VIEWER CON FRECCE */

function setupViewer(sectionId) {
    const section = document.getElementById(sectionId);
    if (!section) return;

    const pages = section.querySelectorAll('.pagina');
    let current = 0;

    function showPage(n) {
        if (n < 0 || n >= pages.length) return;

        pages.forEach(p => p.style.display = 'none');
        pages[n].style.display = 'flex';
        current = n;

        ridimensionaZone(pages[n]);
    }

    pages.forEach(pagina => {
        const left = document.createElement('div');
        left.className = 'freccia sinistra';
        left.innerHTML = '&#10094;';
        left.onclick = () => showPage(current - 1);

        const right = document.createElement('div');
        right.className = 'freccia destra';
        right.innerHTML = '&#10095;';
        right.onclick = () => showPage(current + 1);

        pagina.prepend(left);
        pagina.append(right);
    });

    showPage(0);
}

/* SCALATURA AUTOMATICA DELLE ZONE */

function ridimensionaZone(pagina) {
    const img = pagina.querySelector("img");
    const zones = pagina.querySelectorAll(".zona");

    if (!img) return;

    const originalW = parseFloat(img.dataset.originalWidth);
    const originalH = parseFloat(img.dataset.originalHeight);

    const displayedW = img.clientWidth;
    const displayedH = img.clientHeight;

    const scaleX = displayedW / originalW;
    const scaleY = displayedH / originalH;

    zones.forEach(z => {
        const ulx = parseFloat(z.dataset.ulx);
        const uly = parseFloat(z.dataset.uly);
        const lrx = parseFloat(z.dataset.lrx);
        const lry = parseFloat(z.dataset.lry);

        z.style.left   = (ulx * scaleX) + "px";
        z.style.top    = (uly * scaleY) + "px";
        z.style.width  = ((lrx - ulx) * scaleX) + "px";
        z.style.height = ((lry - uly) * scaleY) + "px";
    });
}

/* TOOLTIP VISIVO */

function setupTooltipVisuale() {

    // crea il box tooltip
    const tooltipBox = document.createElement("div");
    tooltipBox.id = "tooltip-box";
    tooltipBox.style.position = "absolute";
    tooltipBox.style.padding = "8px 10px";
    tooltipBox.style.background = "rgba(0,0,0,0.85)";
    tooltipBox.style.color = "white";
    tooltipBox.style.borderRadius = "6px";
    tooltipBox.style.fontSize = "14px";
    tooltipBox.style.maxWidth = "320px";
    tooltipBox.style.display = "none";
    tooltipBox.style.zIndex = "9999";
    tooltipBox.style.pointerEvents = "none";
    tooltipBox.style.lineHeight = "1.4";

    document.body.appendChild(tooltipBox);

    // attiva tooltip su tutti gli elementi con classe .tooltip
    document.querySelectorAll(".tooltip").forEach(el => {

        el.addEventListener("mouseenter", e => {
            const info = el.dataset.info;
            if (info) {
                // trasforma " | " in righe separate
                tooltipBox.innerHTML = info.replace(/\s*\|\s*/g, "<br>");
                tooltipBox.style.display = "block";
            }
        });

        el.addEventListener("mousemove", e => {
            tooltipBox.style.left = (e.pageX + 15) + "px";
            tooltipBox.style.top = (e.pageY + 15) + "px";
        });

        el.addEventListener("mouseleave", () => {
            tooltipBox.style.display = "none";
        });

    });
}

/* CLICK SU ZONA → MOSTRA SOLO QUEL PARAGRAFO */

function setupZoneClick() {

    document.querySelectorAll(".zona").forEach(zona => {

        zona.style.pointerEvents = "auto";  // rende cliccabile

        zona.addEventListener("click", () => {

            const id = zona.dataset.corresp; // es: p3_x

            const pagina = zona.closest(".pagina");
            const boxTesto = pagina.querySelector(".testo");
            const nascosti = pagina.querySelector(".testo-nascosto");

            const paragrafo = nascosti.querySelector(`[data-corresp="${id}"]`);

            boxTesto.innerHTML = "";

            if (paragrafo) {
                boxTesto.appendChild(paragrafo.cloneNode(true));
            }

            // highlight zona selezionata
            pagina.querySelectorAll(".zona").forEach(z => z.classList.remove("highlight"));
            zona.classList.add("highlight");
        });

    });

}

/* EVENTI GLOBALI */

window.addEventListener('load', () => {

    setupViewer('articolo-x');
    setupViewer('articolo-per-sempre');
    setupViewer('articolo-bibliografia');
    setupViewer('articolo-notizie');

    setupZoneClick();
    setupTooltipVisuale();   // <--- ATTIVAZIONE TOOLTIP

    // BOTTONE TOGGLE COLORI CATEGORIE
    const toggleBtn = document.getElementById("toggle-colors");
    if (toggleBtn) {
        toggleBtn.addEventListener("click", () => {
            document.body.classList.toggle("color-categories");
            toggleBtn.textContent = document.body.classList.contains("color-categories")
                ? "Nascondi colori categorie"
                : "Mostra colori categorie";
        });
    }

    // BOTTONE TORNA AL MENU
    document.querySelectorAll(".btn-back-menu").forEach(btn => {
        btn.addEventListener("click", () => {
            const menu = document.querySelector(".menu-principale");
            if (menu) {
                menu.scrollIntoView({ behavior: "smooth" });
            }
        });
    });

    // RIDIMENSIONAMENTO AL RESIZE
    window.addEventListener("resize", () => {
        document.querySelectorAll(".pagina").forEach(p => {
            if (p.style.display !== "none") ridimensionaZone(p);
        });
    });
});

document.addEventListener("DOMContentLoaded", function() {
    // prende tutti i <p> della pagina
    const paragraphs = document.getElementsByTagName("p");

    for (let p of paragraphs) {
        if (p.textContent.includes("GitHub")) {
            
            // URL preso dal tuo XML
            const url = "https://github.com/martox05/progetto_codifica";

            // sostituisce "GitHub" con link cliccabile
            p.innerHTML = p.innerHTML.replace(
                "GitHub",
                `<a href="${url}" target="_blank">GitHub</a>`
            );
        }
    }
});