document.addEventListener('DOMContentLoaded', function() {
  var header = document.querySelector('.md-header__inner');
  var nav = document.querySelector('.md-sidebar--primary');
  var main = document.querySelector('.md-main');
  var container = document.querySelector('.md-container');

  if (header && nav && main && container) {
    var toggle = document.createElement('button');
    toggle.classList.add('md-sidebar-toggle');
    toggle.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M3 6h18v2H3V6m0 5h18v2H3v-2m0 5h18v2H3v-2z"/></svg>';
    header.insertBefore(toggle, header.firstChild);

    toggle.addEventListener('click', function() {
      container.classList.toggle('sidebar-hidden');
    });
  }
});
