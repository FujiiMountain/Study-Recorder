// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .
//= require chartkick
//= require Chart.bundle
//= require jquery
//= require jquery_ujs

$(document).on('turbolinks:load', function() {
  $('footer').css('width', $('#main').outerWidth());

  $('#chart-1').css('height', $(window).innerHeight() - $('nav').outerHeight() - $('footer').outerHeight() - $('h1').outerHeight() - 100);
  // #chart-1の高さの決定を待つためsetTimeoutを使用 →  ない場合、/tasksで条件分岐がtrueになる
  setTimeout(function() {
    if( $(window).innerHeight() < $('footer').offset().top + $('footer').outerHeight() ) {
      $('body').css('height', 'auto');
      $('#main').css('height', 'auto');
    } else {
      $('body').css('height', $(window).innerHeight());
      $('#main').css('height', $(window).innerHeight() - $('nav').outerHeight() - 20);
      $('footer').css('position', 'fixed');
      $('footer').css('bottom', '0');
    }
    $('.content_space').css('width', $('#main').width());
    $('.content_space').css('height', $('#main').outerHeight() - $('h1').outerHeight() - $('footer').outerHeight());
    $('.content').css('padding', ($('.content').height() * 0.2) + "px 0  0  30px");
  }, 0);

});
