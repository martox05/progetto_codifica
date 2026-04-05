<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="1.0">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="tei:rs">
  <xsl:choose>

    <!-- SOLO se ha anche @ref -->
    <xsl:when test="(@type='person' or @type='place' or @type='term') and @ref">
      <span class="rs {@type} tooltip" data-info="{@ref}">
        <xsl:apply-templates/>
      </span>
    </xsl:when>

    <!-- tutti gli altri -->
    <xsl:otherwise>
      <span class="rs {@type}">
        <xsl:apply-templates/>
      </span>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>


  <!-- TEMPLATE PRINCIPALE -->
  <xsl:template match="/tei:TEI">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title>Rassegna Settimanale</title>
        <link rel="stylesheet" href="stile.css"/>
        <script src="script.js"></script>
      </head>

      <body>

        <!-- HEADER -->
        <header class="site-header">
          <h1>Rassegna Settimanale</h1>
          <h2>di Politica, Scienze, Lettere ed Arti</h2>

          <nav class="menu-principale">
            <ul>
              <li><a href="#articolo-x">X</a></li>
              <li><a href="#articolo-per-sempre">Per Sempre</a></li>
              <li><a href="#articolo-bibliografia">Bibliografia</a></li>
              <li><a href="#articolo-notizie">Notizie</a></li>
              <li><a href="#informazioni">Informazioni</a></li>
            </ul>
          </nav>
        </header>

        <!-- LEGENDA COLORI -->
        <xsl:call-template name="legenda-colori"/>

        <!-- BOTTONE PER COLORARE LE CATEGORIE -->
        <div style="text-align:center; margin: 1rem 0;">
            <button id="toggle-colors" type="button">Mostra colori categorie</button>
        </div>

        <!-- SEZIONI ARTICOLI -->
        <section id="articolo-x">
          <h2>X</h2>
          <xsl:call-template name="viewer-articolo">
            <xsl:with-param name="prefix" select="'x'"/>
          </xsl:call-template>
        </section>

        <section id="articolo-per-sempre">
          <h2>Per Sempre</h2>
          <xsl:call-template name="viewer-articolo">
            <xsl:with-param name="prefix" select="'per_sempre'"/>
          </xsl:call-template>
        </section>

        <section id="articolo-bibliografia">
          <h2>Bibliografia</h2>
          <xsl:call-template name="viewer-articolo">
            <xsl:with-param name="prefix" select="'bibliografia'"/>
          </xsl:call-template>
        </section>

        <section id="articolo-notizie">
          <h2>Notizie</h2>
          <xsl:call-template name="viewer-articolo">
            <xsl:with-param name="prefix" select="'notizie'"/>
          </xsl:call-template>
        </section>

        <!-- SEZIONE INFORMAZIONI -->
        <section id="informazioni">
          <h2>Informazioni</h2>
          <xsl:call-template name="info-header"/>
        </section>

        <!-- DIZIONARI PER TOOLTIP: COPIA INTEGRALE DEL BACK -->
        <div id="dizionari" style="display:none;">
          <xsl:copy-of select="/tei:TEI/tei:text/tei:back"/>
        </div>

        <!-- FOOTER -->
        <footer class="site-footer">
          <p>Edizione digitale a cura di Martina Marchesini</p>
          <p>Università di Pisa — 2026</p>
        </footer>

      </body>
    </html>
  </xsl:template>

  <!-- VIEWER PER ARTICOLO -->
<xsl:template name="viewer-articolo">
  <xsl:param name="prefix"/>

  <div class="viewer">

    <div class="istruzioni-viewer">
      Clicca sulle aree dell’immagine per visualizzare il testo corrispondente, utilizza le frecce per cambiare pagina.
    </div>

    <xsl:for-each select="/tei:TEI/tei:facsimile/tei:surface[contains(@corresp, $prefix)]">

      <xsl:variable name="img" select="tei:graphic"/>

      <div class="pagina">

        <div class="immagine-container">
          <img src="immagini/{$img/@url}"
               width="{$img/@width}"
               height="{$img/@height}"
               data-original-width="{$img/@width}"
               data-original-height="{$img/@height}"/>

          <xsl:for-each select="tei:zone">
            <div class="zona"
                 data-corresp="{@corresp}"
                 data-ulx="{@ulx}"
                 data-uly="{@uly}"
                 data-lrx="{@lrx}"
                 data-lry="{@lry}">
            </div>
          </xsl:for-each>
        </div>

        <div class="testo">
          <div class="testo-placeholder">
            Passa il mouse sopra nomi propri di persone, luoghi o termini per visualizzare informazioni aggiuntive.
          </div>
        </div>

        <div class="testo-nascosto" style="display:none;">
          <xsl:for-each select="tei:zone">
            <xsl:variable name="id" select="@corresp"/>
            <xsl:for-each select="/tei:TEI/tei:text/tei:body//*[@xml:id = $id]">
                <p data-corresp="{$id}">
                    <xsl:apply-templates/>
                </p>
            </xsl:for-each>
          </xsl:for-each>
        </div>

      </div>
    </xsl:for-each>

    <!-- BOTTONE TORNA AL MENU -->
    <div class="bottom-buttons" style="text-align:center; margin-top:1rem;">
      <button class="btn-back-menu">Torna al menù</button>
    </div>

  </div>
</xsl:template>

  <!-- TEMPLATE PARAGRAFO -->
  <xsl:template match="tei:p">
    <p class="paragrafo" id="{@xml:id}" data-corresp="{@xml:id}">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:lb"><br/></xsl:template>
  <xsl:template match="tei:pb"/>
  <xsl:template match="tei:cb"/>

 
  <!--   TOOLTIP PERSONE               -->

  <xsl:template match="tei:persName">
  <xsl:variable name="id" select="substring-after(@ref, '#')"/>
  <xsl:variable name="entry" select="/tei:TEI/tei:text/tei:back//tei:person[@xml:id=$id]"/>

  <span class="tooltip" data-id="{$id}">
    <xsl:attribute name="data-info">

      <!-- Nome sempre presente -->
      <xsl:text>Nome: </xsl:text>
      <xsl:value-of select="$entry/tei:persName/tei:forename"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$entry/tei:persName/tei:surname"/>

      <!-- Nascita se presente -->
      <xsl:if test="$entry/tei:birth">
        <xsl:text> | Nascita: </xsl:text>
        <xsl:value-of select="$entry/tei:birth/@when"/>
        <xsl:if test="$entry/tei:birth/tei:placeName">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="$entry/tei:birth/tei:placeName"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>

      <!-- Morte se presente -->
      <xsl:if test="$entry/tei:death">
        <xsl:text> | Morte: </xsl:text>
        <xsl:value-of select="$entry/tei:death/@when"/>
        <xsl:if test="$entry/tei:death/tei:placeName">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="$entry/tei:death/tei:placeName"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>

      <!-- Note se presenti -->
      <xsl:if test="$entry/tei:note">
        <xsl:text> | Note: </xsl:text>
        <xsl:value-of select="normalize-space($entry/tei:note)"/>
      </xsl:if>

    </xsl:attribute>

    <xsl:apply-templates/>
  </span>
</xsl:template>


  <!--   TOOLTIP LUOGHI                -->

  <xsl:template match="tei:placeName">
  <xsl:variable name="id" select="substring-after(@ref, '#')"/>
  <xsl:variable name="entry" select="/tei:TEI/tei:text/tei:back//tei:place[@xml:id=$id]"/>

  <span class="tooltip" data-id="{$id}">
    <xsl:attribute name="data-info">

      <!-- Luogo sempre presente -->
      <xsl:text>Luogo: </xsl:text>
      <xsl:value-of select="$entry/tei:placeName"/>

      <!-- Regione se presente -->
      <xsl:if test="$entry/tei:region">
        <xsl:text> | Regione: </xsl:text>
        <xsl:value-of select="$entry/tei:region"/>
      </xsl:if>

      <!-- Paese se presente -->
      <xsl:if test="$entry/tei:country">
        <xsl:text> | Paese: </xsl:text>
        <xsl:value-of select="$entry/tei:country"/>
      </xsl:if>

      <!-- Note se presenti -->
      <xsl:if test="$entry/tei:note">
        <xsl:text> | Note: </xsl:text>
        <xsl:value-of select="normalize-space($entry/tei:note)"/>
      </xsl:if>

    </xsl:attribute>

    <xsl:apply-templates/>
  </span>
</xsl:template>

  
  <!--   TOOLTIP TERMINI               -->

  <xsl:template match="tei:term">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="entry" select="/tei:TEI/tei:text/tei:back//tei:item[@xml:id=$id]"/>

    <span class="tooltip" data-id="{$id}">
      <xsl:attribute name="data-info">
        <xsl:value-of select="normalize-space($entry/tei:note)"/>
      </xsl:attribute>

      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- SURNAME -->
  <xsl:template match="tei:surname">
    <span class="surname">
      <xsl:apply-templates/>
    </span>
  </xsl:template>


<!--   NUMERI                         -->
<xsl:template match="tei:num">
  <span class="num">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- TEMPLATE PER DATE -->
<xsl:template match="tei:date">
  <span class="num date">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!--TEMPLATE PER CITAZIONI-->
<xsl:template match="tei:q">
  <span class="q">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!--TEMPLATE ENFASI-->
<xsl:template match="tei:emph">
  <span class="emph">
    <xsl:apply-templates/>
  </span>
</xsl:template>


<!--   PARTI DEL GIORNO               -->
<xsl:template match="tei:time[@type='partOfDay']">
  <span class="time">
    <xsl:apply-templates/>
  </span>
</xsl:template>

  <!-- TEMPLATE INFORMAZIONI -->
  <xsl:template name="info-header">
    <div class="info-header">

      <h3>Titolo</h3>
      <p>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']"/>
        —
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='sub']"/>
      </p>

      <h3>Fondatori</h3>
      <ul>
        <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[tei:resp=' Fondatori: ']/tei:persName">
          <li><xsl:value-of select="."/></li>
        </xsl:for-each>
      </ul>

      <h3>Edizione</h3>
      <p>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition"/>
        (<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:date/@when"/>)
      </p>

      <h3>Coordinatore</h3>
      <p>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:persName"/>
      </p>

      <h3>Pubblicazione</h3>
      <p>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher"/>,
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace"/>
        (<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when"/>)
      </p>

      <h3>Serie</h3>
      <p>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:title"/>
      </p>

      <h3>Codifica</h3>
      <p>
        <xsl:text>Codifica a cura di </xsl:text>
        <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:respStmt/tei:persName"/>
      </p>

      <h3>Fonti</h3>
<ul>
  <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct">
    <li>
      <strong><xsl:value-of select="tei:analytic/tei:title"/></strong>

      <xsl:if test="tei:analytic/tei:author/tei:persName">
        , <xsl:value-of select="tei:analytic/tei:author/tei:persName"/>
      </xsl:if>

      <xsl:if test="tei:monogr/tei:imprint/tei:pubPlace">
        — <xsl:value-of select="tei:monogr/tei:imprint/tei:pubPlace"/>
      </xsl:if>

      <xsl:if test="tei:monogr/tei:imprint/tei:publisher">
        , <xsl:value-of select="tei:monogr/tei:imprint/tei:publisher"/>
      </xsl:if>

      <xsl:if test="tei:monogr/tei:imprint/tei:date/@when">
        , <xsl:value-of select="tei:monogr/tei:imprint/tei:date/@when"/>
      </xsl:if>
    </li>
  </xsl:for-each>
</ul>

    </div>
  </xsl:template>

<!--   LEGENDA COLORI             -->
<xsl:template name="legenda-colori">
  <section id="legenda-colori">
    <h3>Legenda dei colori</h3>
    <ul class="legenda-lista">
      <li><span class="rs place">Luoghi comuni</span> — es. casa, chiesa</li>
      <li><span class="rs bodyPart">Parti del corpo</span> — es. mano, testa</li>
      <li><span class="rs personGroup">Gruppi di persone</span> — es. fanciulli, bambini</li>
      <li><span class="rs plant">Piante</span> — es. gigli, fiori</li>
      <li><span class="rs object">Strumenti</span> — es. organetto, piano</li>
      <li><span class="time">Parti del giorno</span> — es. mattina, pomeriggio, notte</li>
      <li><span class="num">Numeri</span> — es. 1, ventidue</li>
      <li><span class="num date">Date</span> — es. 1881, 1219</li>
      <li><span class="q">Citazioni</span></li>
      <li><span class="emph">Enfasi</span></li>
    </ul>
  </section>
</xsl:template>

</xsl:stylesheet>
