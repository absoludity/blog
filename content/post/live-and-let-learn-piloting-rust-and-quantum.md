---
title: "Live and Let Learn with Rust, Quantum Computing and Piloting aeroplanes"
date: 2024-02-22T16:25:25+11:00
draft: false
categories: [ "programming", "aviation", "science", "life", "learning", "rust", "piloting", "quantum-computing"]
featured: true
tags: ["article"]
commentable: true
---

In mid 2022 I was presented with an **amazing opportunity** through no effort of my own: VMware, the company I worked for, announced it was being acquired by a non-remote, non-open-source-oriented multi-national in a somewhat lengthy 18 month process. As a fully-remote staff engineer on an open-source project **I estimated a 75 to 90 percent probability that I'd receive a redundancy in around 18 months time**.

A redundancy, really? An amazing opportunity? This post is a personal reflection and reminder to my future self to step back and evaluate the potential opportunities that a situation provides. I'm currently using this opportunity to **weave three passions of mine into a possible future of software engineering with Rust on quantum computing projects and piloting aeroplanes on the side**. Sure, reality may force me to compromise in one way or another in time, but for now I'm leaving my options open.

<!--more-->

## A future acquisition and probable redundancy

Normally a potential redundancy isn't necessarily associated with amazing opportunities, and more to the point, I loved my role as a Staff Software engineer on the open source [Kubeapps project](https://kubeapps.dev/): I had great team-mates and I enjoyed the combination of [Go](https://go.dev) and [Rust](https://rust-lang.org) with a bearable amount of [React/Javascript](https://react.dev), as well as the [interesting problems that we got to solve]({{<relref "fan-out-fan-in-golang-with-kubeapps">}}). So I didn't initially think of a probable redundancy as an opportunity either.

![Broadcom / VMware](/img/live-and-let-learn-piloting-rust-and-quantum/gemini-test.png)

It was only when I stepped back to evaluate what my next steps might be that I realised: I could start looking for another interesting software engineering role straight away and avoid the long drawn-out acquisition (like quite a few people did). Or I could use the approximately 18 months of paid work on an open-source project that I enjoy, while also **re-evaluating my life goals and planning how I might best utilise the probable redundancy period and the future beyond**. Once I viewed the situation this way, it was hard to ignore the opportunity that had presented itself.

## Rust for the future

The first thing I did was apply for a program within VMware to spend 3 months working on a project written in the [Rust](https://rust-lang.org) programming language with experienced Rust developers. I'd learned Rust for fun in the early days and more recently designed and implemented one of the Kubeapps backend services in Rust, but I was keen to learn from others and get more exposure to the type system and tooling of the language. This resulted in a wonderful three months with [Leonid and the crew](https://www.feldera.com/about-us) on the Database Stream Processing project. I wrote a [review of my three months work on the DBSP project at the time]({{<relref "vmware-take-3-experience-with-rust-and-dbsp">}}) and the code-base has since forked to the [Feldera repository](https://github.com/feldera/feldera) and is the basis for the [Feldera](https://www.feldera.com/) service - real-time data analytics for live-streaming sources.

The three month experience re-enforced **how much I enjoy expressing ideas and solutions efficiently in Rust and resolved my goal to learn the language intimately**. I'm currently continuing this goal by working through the excellent [Rust for Rustaceans: Idiomatic Programming for Experienced Developers](https://www.amazon.com.au/Rust-Rustaceans-Programming-Experienced-Developers/dp/1718501854/) book by Jon Gjengset, among other Rust tasks such as [Advent of code]({{<relref "day03-enums-and-docstrings">}}) or the occasional leetcode problem.

## Becoming a Pilot on the side...

At the same time in mid 2022, I began thinking about how I can best use a probable redundancy to achieve other life goals. I was looking for **something that I'm passionate about** that I can progress slowly on the side next to work for a year before then **focusing on and completing in a probable redundancy period**, making the most of the opportunity.

Two years earlier I began a journey towards a life-long goal to fly when [I learned to fly a paraglider]({{<relref "learning-to-paraglide">}}). I've been flying paragliders locally ever since in my spare time and have had some memorable flights with friends, such as flying 90kms, powered only by thermals in the air, from Blackheath to Lake Windermere near Mudgee. Like many people, I've always dreamed of flying and the reality did not disappoint - being in the air feels somehow natural (as unnatural as I know is it is for an 80kg lump of flesh to be suspended high above the ground).

Although I didn't see a future where I could be paid to fly a paraglider, after chatting with numerous friends in different stages of their flying careers **I did see a possibility of working towards being paid a little to fly small planes, while continuing my normal line of work** as a software engineer or consultant, or even potentially merging those two passions, [developing software or controllers for electric aircraft or avionics](https://www.baesystems.com/en/product/aircraft-electrification). So I began taking an occasional flying lesson at the excellent [WardAir in Bathurst](https://wardair.com.au/), while beginning the study towards my commercial pilots license theory examinations in the evenings and on weekends. **By the time the acquisition went through I'd completed five of the seven commercial pilot examinations.**

## Maximising redundancy

A month or so after the acquisition finally went through, the redundancy notice was issued to many of us on open-source projects and so, after a lovely few weeks in summer relaxing with my family, I began to focus half my time on my planned pilot qualification (which I'll write about separately) while simultaneously **evaluating which niche domain I might focus my software engineering and Rust learning on while I have the opportunity**.

## Quantum computing with Rust

Since university I've been combining my passion for physics - **understanding the universe around me** - with computer science and engineering. From second year I filled all my Comp. Sci. electives with quantum physics and relativity subjects and in my final year implemented a 3D relativistic renderer for my thesis on one of UNSW's first [Silicon Graphics O2](https://en.wikipedia.org/wiki/SGI_O2) workstations. A few years later I was exposed to the beautiful mathematical language of [Geometric Algebra](https://bivector.net) and have since spent way too much time exploring how Geometric Algebra provides a simpler, more intuitive way to understand many physical phenomena. I even created the website [Geometry of Relativity](https://geometry-of-relativity.net) as a way to help people with an inclination to see the beauty in [Special Relativity as a simple rotation in space-time](https://geometry-of-relativity.net/rotations-in-spacetime/2d-rotations-in-spacetime/) (not a new concept, but beautiful nonetheless).

This passion has lead me back to quantum mechanics and, in particular, quantum computing - an exciting area of computer science and software engineering that hasn't yet reached market maturity. I plan to write more about Quantum Computing in the future but for now I'm loving [IBM's excellent set of Quantum Computing courses](https://learning.quantum.ibm.com/catalog/courses) that, while they don't shy away from the mathematics, are **phenomenal examples of self-paced, quality online education with clearly defined learning expectations** especially when combined with the accompanying video lectures by John Watrous - the technical director from IBM Quantum Education - adding a more human touch to an anonymous learning interaction. Of course you can also try out all the examples using [IBM's open-source Qiskit toolkit](https://www.ibm.com/quantum/qiskit) as part of the lecture itself.

Of particular interest to me is that [parts of IBM's Qiskit are being re-implemented in Rust](https://medium.com/qiskit/new-weve-started-using-rust-in-qiskit-for-better-performance-a3676433ca8c), so there may be some opportunities to get involved in an open-source project which combines Rust and Quantum Computing.

## Available for hire

I now have some months where I can enjoy living and learning - re-evaluating and redirecting my software engineering career while pushing forward with my pilot license. Of course, when I start looking for work I'm not expecting to find the perfect Rust consulting/contract position which integrates quantum computing or aviation: it may be a go-lang and React role for an unrelated domain, or a role picking up and helping lead a struggling remote team or project. But while I have the opportunity **I am going to use this planned redundancy to get involved in the specific areas that I am interested in personally and see what opportunities may be there**.

If you've read this far you're either my parents or you happen to have similar interests in Rust, Quantum Computing or flying (or all three). If you're interested in chatting about any of the above, or working together, do get in touch (absoludity at gmail dot com)!
