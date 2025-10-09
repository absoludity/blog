---
# Leave the homepage title empty to use the site title
title: ""
date: 2022-10-24
type: landing

design:
  # Default section spacing
  spacing: "6rem"

sections:
  - block: hero
    content:
      title: |
        Live and let Learn
      text: |
        <br>

        **Living and learning together**

        I'm Michael Nelson, I write software, fly planes, explore science and love learning new things with people.


    design:
      background:
        image:
          filename: flying_over_scattered.jpg
          focal_point: Bottom
          filters:
            brightness: 0.8
        text_color_light: true
      spacing:
        padding: ['20px', '0', '20px', '0']

  - block: collection
    content:
      title: Recent Learning Bites
      subtitle: 'Short thoughts and updates'
      text: ''
      # Choose how many pages you would like to display (0 = all pages)
      count: 5
      # Filter on criteria
      filters:
        # The folders to display content from
        folders:
          - post
        tag: "note"
      # Choose how many pages you would like to offset by
      offset: 0
      # Page order: descending (desc) or ascending (asc) date.
      order: desc
    design:
      # Choose a layout view
      view: compact
      columns: '1'

  - block: collection
    content:
      title: Latest Posts
      subtitle: Longer-form learning when I have the time
      text: ''
      # Choose how many pages you would like to display (0 = all pages)
      count: 3
      # Filter on criteria
      filters:
        # The folders to display content from
        folders:
          - post
        tag: "article"
      # Choose how many pages you would like to offset by
      offset: 0
      # Page order: descending (desc) or ascending (asc) date.
      order: desc
    design:
      # Choose a layout view
      view: card
      columns: '1'
      # Show excerpt with read more link
      show_excerpt: true
      excerpt_length: 300

  - block: markdown
    content:
      title: |
        Areas of Interest
      text: |
        <div class="row">
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-code fa-3x mb-3" style="color: #2196F3;"></i>
              <h4><a href="/category/programming/" style="text-decoration: none; color: inherit;">Software Engineering</a></h4>
              <p>Kubernetes, Rust, Python, Go, and cloud-native technologies. Building scalable systems and contributing to open source.</p>
              <p><a href="/category/programming/" class="btn btn-outline-primary btn-sm">View Programming Posts →</a></p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-plane fa-3x mb-3" style="color: #FF9800;"></i>
              <h4><a href="/category/aviation/" style="text-decoration: none; color: inherit;">Aviation & Flying</a></h4>
              <p>Commercial pilot, glider and paragliding enthusiast. Exploring the physics of flight and enjoying the freedom of moving in three dimensions.</p>
              <p><a href="/category/aviation/" class="btn btn-outline-warning btn-sm">View Aviation Posts →</a></p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-atom fa-3x mb-3" style="color: #9C27B0;"></i>
              <h4><a href="/category/science/" style="text-decoration: none; color: inherit;">Science &amp; Quantum Computing</a></h4>
              <p>Understanding quantum mechanics and the simulation of quantum computation on traditional computers.</p>
              <p><a href="/category/science/" class="btn btn-outline-secondary btn-sm">View Science Posts →</a></p>
            </div>
          </div>
        </div>

  - block: collection
    content:
      title: Featured Topics
      text: ""
      filters:
        folders:
          - post
        featured_only: true
    design:
      view: card
      columns: 2

  - block: contact
    content:
      title: Connect
      text: |
        Find me on these platforms or get in touch via email.
      email: absoludity+lll@gmail.com
      contact_links:
        - icon: linkedin
          icon_pack: fab
          name: LinkedIn
          link: "https://www.linkedin.com/in/michael-nelson-a4900a1/"
        - icon: github
          icon_pack: fab
          name: GitHub
          link: "https://github.com/absoludity"
        - icon: mastodon
          icon_pack: fab
          name: Mastodon
          link: "https://aus.social/@miken"
    design:
      columns: '1'

---
