# Rules aligned with the GA4 report; first matching rule wins.
classify_page <- function(page) {
  dplyr::case_when(

      page == "/" ~
        "Homepage",

      stringr::str_detect(
        page,
        "science-talent-search|^/sts-"
      ) ~
        "Science Talent Search",

      stringr::str_detect(
        page,
        "^/event/|^/events|^/events-calendar|^/workshops|conference|stavcon|call-for-abstracts|submitting-a-session|^/series/|^/venue/|^/organiser/"
      ) ~
        "Events & Conferences",

      stringr::str_detect(
        page,
        "^/publications|^/resources|^/stav-publishing|labtalk|conference-resources|teaching-science-journals|lets-find-out"
      ) ~
        "Resources & Publications",

      stringr::str_detect(
        page,
        "science-in-construction|national-science-week"
      ) ~
        "Science Programs & Initiatives",

      stringr::str_detect(
        page,
        "^/shop|^/product|^/product-category|^/cart|^/checkout"
      ) ~
        "Shop",

      stringr::str_detect(
        page,
        "member|membership"
      ) ~
        "Membership",

      stringr::str_detect(
        page,
        "^/my-account|^/login"
      ) ~
        "Account",

      stringr::str_detect(
        page,
        "^/about-us|^/our-team|^/contact-us|^/contact-archive|^/stav-council|^/our-partners|annual-general-meeting|^/our-history|working-party-committees|stav-80th-anniversary"
      ) ~
        "Organisation",

      stringr::str_detect(
        page,
        "^/forums|^/discussion-forums"
      ) ~
        "Forums / Community",

      stringr::str_detect(
        page,
        "^/wp-content/uploads/"
      ) ~
        "Files",

      stringr::str_detect(
        page,
        "^/gh"
      ) ~
        "System / Preferences",

      TRUE ~
        "Other"
    )
}
