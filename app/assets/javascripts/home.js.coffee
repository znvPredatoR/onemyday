# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $('#userDropdown').css("width", $("#userMenu").width())

  $('#storiesContainer').masonry
    itemSelector: '.smallStory'

  if $('.pagination')[0]
    $(window).scroll ->
      url = $('.pagination .next_page a').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("Fetching more stories...")
        $.getScript(url)

    $(window).scroll()

  $("#navbarSearch").focus(->
    $(@).css(backgroundColor: "#ffffff")
  ).blur(->
    $(@).css(backgroundColor: "#eaeaea")
  )

  # Google analytics.
  _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-34912967-1']);
  _gaq.push(['_trackPageview']);

  if !$("#ga")[0]
    js = $("<script id='ga' src='//google-analytics.com/ga.js'></script>")
    $("script:first").parent().prepend(js)
)