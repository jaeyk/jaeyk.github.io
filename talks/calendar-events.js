document.addEventListener('DOMContentLoaded', function () {
  var calendarEl = document.getElementById('calendar');

  var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: 'dayGridMonth',
    height: "auto",
    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: 'dayGridMonth,listWeek'
    },
    events: [
      {
        title: "Peace & Democracy Institute, Korea Univ.",
        start: "2025-06-20",
        description: "Invited talk (scheduling)"
      },
      {
        title: "KIXLAB, KAIST",
        start: "2025-06-19",
        description: "Invited talk (scheduled)"
      },
      {
        title: "Entangled with Books, Seoul",
        start: "2025-06-17",
        description: "Locally owned bookstore (scheduled)"
      },
      {
        title: "Yonsei University",
        start: "2025-06-13",
        description: "Invited talk (scheduling)"
      },
      {
        title: "GSIS, Korea Univ.",
        start: "2025-06-10",
        description: "Invited talk (scheduled)"
      },
      {
        title: "PMRC, Seoul National Univ.",
        start: "2025-06-26",
        description: "Conference presentation (scheduled)"
      },
      {
        title: "Knowledge Festival, SKMS",
        start: "2025-06-27",
        end: "2025-06-28",
        description: "Conference (scheduled)"
      },
      {
        title: "Code for America Summit",
        start: "2025-05-29",
        end: "2025-05-30",
        url: "https://summit.codeforamerica.org/"
      },
      {
        title: "NLP for CSS, Johns Hopkins",
        start: "2025-04-07",
        description: "Invited talk"
      },
      {
        title: "American Politics Workshop, Northwestern",
        start: "2025-02-26",
        url: "https://planitpurple.northwestern.edu/event/625048"
      }
      // Add more here (2024 events, etc.)
    ],
    eventClick: function (info) {
      info.jsEvent.preventDefault(); // prevent default browser behavior
      if (info.event.url) {
        window.open(info.event.url, "_blank");
      } else if (info.event.extendedProps.description) {
        alert(info.event.title + "\n\n" + info.event.extendedProps.description);
      }
    }
  });

  calendar.render();
});
