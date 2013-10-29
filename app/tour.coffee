# Snippet from stackoverflow to invoke a click() d3 will recognise
jQuery.fn.d3Click = () ->
    this.each( (i, e) ->
        evt = document.createEvent("MouseEvents")
        evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)

        e.dispatchEvent(evt)
    )

tour_steps =
  [
    title: "<strong>Vennt!</strong>"
    content: "This web tool can be used to explore overlap between gene lists.  The filters for significance can be dynamically updated; the intersection and difference between gene-lists displayed in a table and downloaded."
    orphan: true
    backdrop: true
  ,
    title: "Gene Lists"
    content: "This shows the gene lists.  You can select a single list and all the genes from that list will be shown in the gene table below."
    element: '#files li:first a'
  ,
    title: "Significantly Differentially Expressed Genes"
    content: "The number of genes that are significantly differentially expressed, as filtered by the FDR and log fold-change thresholds.<br/><strong>Click on these numbers to select the list for the Venn diagram</strong>"
    element: '#files li:first .total'
  ,
    title: "Significantly <strong>UP</strong> Differentially Expressed Genes"
    content: "Number of gene significantly UP (positive log fold-change).<br/><strong>Click on these numbers to select the list for the Venn diagram</strong>"
    element: '#files li:first .up'
  ,
    title: "Significantly <strong>DOWN</strong> Differentially Expressed Genes"
    content: "Number of gene significantly DOWN (negative log fold-change).<br/><strong>Click on these numbers to select the list for the Venn diagram</strong>"
    element: '#files li:first .down'
  ,
    title:"<strong>FDR threshold</strong>"
    content: "Modify the threshold for False-Discovery-Rate.  The numbers in the table above, and in the Venn diagram are updated dynamically."
    element: '.fdr'
  ,
    title:"<strong>log fold-change threshold</strong>"
    content: "Modify the filter for significance using log fold-change.  For example, a setting of '1.0' will determine a gene as significant if it has log fold-change greater than 1.0 or less than -1.0 (that is 2x up or down)."
    element: '.fc'
  ,
    title:"Number of genes"
    content: "Each number in the Venn diagram reprents how many genes are significant in that region of the diagram.  These numbers may be clicked to display the actual genes in the table below."
    element: '.venn-diagram .str:first'
    onNext: () -> $('.venn-diagram .str:first').d3Click()
  ,
    title:"Gene list"
    placement: 'top'
    content: "List of genes, and the fold-change for that gene from each selected gene-list.  The table is sortable. Green indicates a positive log fold-change, red indicates negative.  Genes that are 'not significant' (ie. don't meet the FDR and log fold-change filters above) are shown dimmed."
    element: '#gene-table'
  ,
    title:"Gene list description"
    content: "This describes the current contents of the gene list table.  A 'tick' means genes are significant in that list, a 'cross' means they are not."
    element: '#gene-list-desc ul'
    backdrop: true
  ,
    title:"Gene list download"
    placement: 'left'
    content: "Anything displayed in the gene list table can be downloaded as a CSV file."
    element: '#csv-download'
  ,
    title:"Venn table"
    content: "An alternative to the Venn diagram is a table.  Not as pretty, but necessary when we have more than 4 lists..."
    element: '#overlaps li:first'
  ,
  ]

window.setup_tour = (show_tour) ->
    tour = new Tour()
    tour.addSteps(tour_steps)
    $('a#tour').click(() -> tour.restart())
    tour.start() if show_tour
