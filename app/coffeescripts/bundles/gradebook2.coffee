require [
  'jquery'
  'Backbone'
  'compiled/userSettings'
  'compiled/gradebook2/ReactGradebook'
  'compiled/gradebook2/Gradebook'
  'compiled/views/gradebook/NavigationPillView'
  'compiled/views/gradebook/OutcomeGradebookView'
], ($, Backbone, userSettings, ReactGradebook, Gradebook, NavigationPillView, OutcomeGradebookView) ->

  class GradebookRouter extends Backbone.Router
    routes:
      '': 'tab'
      'tab-:viewName': 'tab'

    initialize: ->
      @isLoaded = false
      @views = {}
      @gradebook_performance_enabled = ENV.GRADEBOOK_OPTIONS.gradebook_performance_enabled
      @views.assignment = @gradebook()

      if ENV.GRADEBOOK_OPTIONS.outcome_gradebook_enabled
        @views.outcome = @initOutcomes()

    gradebook: ->
      if @gradebook_performance_enabled
        new ReactGradebook(ENV.GRADEBOOK_OPTIONS)
      else
        new Gradebook(ENV.GRADEBOOK_OPTIONS)

    initOutcomes: ->
      book = new OutcomeGradebookView(
        el: $('.outcome-gradebook-container'),
        gradebook: @views.assignment)
      book.render()
      @navigation = new NavigationPillView(el: $('.gradebook-navigation'))
      @navigation.on 'pillchange', @handlePillChange
      book

    handlePillChange: (viewname) =>
      @navigate('tab-'+viewname, trigger: true) if viewname

    tab: (viewName) ->
      viewName ||= userSettings.contextGet 'gradebook_tab'
      window.tab = viewName
      viewName = 'assignment' if viewName != 'outcome' || !@views.outcome
      @navigation.setActiveView(viewName) if @navigation
      $('.assignment-gradebook-container, .outcome-gradebook-container').addClass('hidden')
      $(".#{viewName}-gradebook-container").removeClass('hidden')
      @views[viewName].onShow() unless @gradebook_performance_enabled
      userSettings.contextSet 'gradebook_tab', viewName

  @router = new GradebookRouter
  Backbone.history.start()
