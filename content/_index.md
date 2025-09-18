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
      image:
        filename: welcome.jpg
      text: |
        <br>
        
        **Living and learning together** - exploring the intersections of software engineering, aviation, and quantum physics.
        
        I'm Michael Nelson, a software engineer who also pilots aircraft and enjoys diving deep into quantum computing concepts. This is where I share my journey of continuous learning across these fascinating domains.
        
    design:
      background:
        gradient_end: '#1976d2'
        gradient_start: '#004ba0'
        text_color_light: true
      spacing:
        padding: ['20px', '0', '20px', '0']

  - block: collection
    content:
      title: Latest Posts
      subtitle: ''
      text: ''
      # Choose how many pages you would like to display (0 = all pages)
      count: 5
      # Filter on criteria
      filters:
        # The folders to display content from
        folders:
          - post
        author: ""
        category: ""
        tag: ""
        exclude_featured: false
        exclude_future: false
        exclude_past: false
        publication_type: ""
      # Choose how many pages you would like to offset by
      offset: 0
      # Page order: descending (desc) or ascending (asc) date.
      order: desc
    design:
      # Choose a layout view
      view: compact
      columns: '1'

  - block: markdown
    content:
      title: |
        Areas of Interest
      text: |
        <div class="row">
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-code fa-3x mb-3" style="color: #2196F3;"></i>
              <h4>Software Engineering</h4>
              <p>Kubernetes, Rust, Go, and cloud-native technologies. Building scalable systems and contributing to open source.</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-plane fa-3x mb-3" style="color: #FF9800;"></i>
              <h4>Aviation & Flying</h4>
              <p>Private pilot and paragliding enthusiast. Exploring the physics of flight and the joy of three-dimensional travel.</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <i class="fas fa-atom fa-3x mb-3" style="color: #9C27B0;"></i>
              <h4>Quantum Computing</h4>
              <p>Understanding quantum mechanics, quantum algorithms, and the future of computation at the quantum scale.</p>
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
      view: article-grid
      columns: 2

  - block: tag_cloud
    content:
      title: Popular Topics
    design:
      columns: '1'
---