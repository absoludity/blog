---
title: "United Nations Transparency Protocol: transparent facts about products you purchase"
date: 2025-05-29T09:15:09+10:00
draft: false
---

For the past year I've been working with the people at [GoSource](https://gosource.com.au/) around 3 days per week while also working towards my commercial pilot license (more on that journey separately). GoSource are involved in quite a number of interesting projects, but for the past 5 months I've been involved with the [United Nations Transparency Protocol](https://uncefact.github.io/spec-untp/docs/about/), which aims to make product claims easy to verify - claims such as whether the product was produced on land that is [deforestation-free](https://environment.ec.europa.eu/topics/forests/deforestation/regulation-deforestation-free-products_en), or whether a battery in your EV was sourced with components that meet [certain sustainability goals](https://environment.ec.europa.eu/topics/waste-and-recycling/batteries_en).

## What is the UNTP

The problem itself is pretty simple: it's hard for people (whether it be consumers or government organisations) to trust information provided about products at many points in the supply chain - not just the eventual product packaging. You can read more about the United Nations Transparency Protocol or watch an intro video from the [UNTP About page](https://uncefact.github.io/spec-untp/docs/about/), but the official summary there is:

> The United Nations Transparency Protocol (UNTP) aims to support governments and industry with practical measures to counter greenwashing by implementing supply chain traceability and transparency at the scale needed to achieve meaningful impacts on global sustainability outcomes.

I'm not going to go into more detail about the aims and purpose of the UNTP. Instead, I want to
1. give an overview in this post of some of the technology and standards that are being used to support the goals of UNTP (**Verifiable Credentials**, **JSON Linked Data** and **Decentralized Identifiers**), before
2. a follow-up post with a deep-dive into a proof-of-concept tool that I worked on recently that enables building trust information from graphs of UNTP data.

## Verifiable Credentials

The main technology specification on which the UNTP relies is the World Wide Web Consortium's [Verifiable Credential specification](https://www.w3.org/TR/vc-overview/). This specification defines an extensible JSON-based document format for credentials, such as a pilot license or a product accreditation certificate, enabling people or organisations

> to express these sorts of credentials on the Web in a way that is cryptographically secure, privacy respecting, and machine-verifiable

So, for example,
- The importer of a solar battery product may publish a verifiable credential which lists certain claims about the battery meeting specific Australian standards and recommendations. This is the purpose of the UNTP's [Digital Product Passport](https://uncefact.github.io/spec-untp/docs/specification/DigitalProductPassport).
- A solar regulator org in Australia may issue a verifiable credential for the battery product, attesting that the battery conforms to certain standards they have checked that were claimed by the product passport. This is the purpose of the UNTP's [Digital Conformity Credential](https://uncefact.github.io/spec-untp/docs/specification/ConformityCredential).
- An unrelated solar reviews website may also issue a verifiable credential in the form of a UNTP Conformity Credential for the same battery product as part of their review, with their own assessment of the claims made by the product.
- others can (be using tools that) verify cryptographically that each credential was issued by the issuer listed on the credential, such as the solar regulator or the solar review company behind the website, and choose who they trust for their information.

The Verifiable Credential specification enables **cryptographically secure ways to issue credentials** to subjects (people, products, etc.) as well as for people to present partial information from their credentials when requested (for example, to prove your age without exposing your address from your drivers license). The UNTP has adopted the Verifiable Credential specification to be able to build upon the solid foundation of a world-wide standard.

## JSON Linked Data

Verifiable Credentials are published in a format which is not only easy for humans to read, but also **easy for machines to read *and link together***. Verifiable Credentials use [JSON Linked Data, a.k.a. JSON-LD](https://json-ld.org/) which ensures that each JSON credential document includes a specific context so that every property within the document is both:
- a uniquely identifiable piece of information and so won't be confused with identically named properties in other contexts (whether that be other locations in the same document or in other documents), and
- a well-defined piece of information both for a computer (it has a specific type) and a human (it has a specific definition in plain English or the language of your choice)
essentially allowing the information provided by a set of credentials to be linked together and understood consistently, even when they are spread across different locations on the web. Furthermore, **this collected data can be transformed into a graph of inter-related data in a standard format for data interchange on the web** known as the [Resource Description Framework](https://www.w3.org/RDF/). This graph of collected data can then be queried or have inferences built upon it to then evaluate further information, such as whether the data can be trusted, or whether certain claims made in the data have been verified.

JSON-LD seems to be a little polarising in the community with a few strong differing views both for and against. I don't (yet) want to enter that debate but only note from my own experience that, on the one side:
-  the use of JSON-LD does take more time for **developers of a specific credential type** to create and understand the role of the context and JSON-LD specific information (than it would to just created a JSON format themselves). So, for example, we have spent quite a lot of time refactoring earlier versions of the few UNTP credential types (the DigitalProductPassport or the DigitalConformanceCredential, for example) so that they are valid JSON-LD.

But the other side of that is, in my opinion, that:
- **this added complexity is not exposed to the developers (or users) who are using those document formats** (such as those publishing their own credentials or viewing or verifying the credentials of others). Instead, they simply benefit from the extra work that has been done behind the scenes to enable unique, well-defined information that can be collected across the web, understood consistently by both humans and computers and transformed into a graph of information for further processing.


## Decentralized Identifiers

Verifiable Credentials actually belong to a family of W3C specifications that enable a decentralized architecture for the identities used to issue credentials. That is, without necessarily relying on a trusted centralised identification services such as Google, Microsoft, Github, FB or similar, to establish a trustworthy identity (or even relying on ssh key servers for signature verification).

The recently published [Verifiable Credential Data Integrity](https://www.w3.org/TR/vc-data-integrity/) specification builds on the earlier Verifiable Credentials specification and

> describes mechanisms for ensuring the authenticity and integrity of [verifiable credentials](https://www.w3.org/TR/vc-data-model-2.0/#dfn-verifiable-credential) and similar types of constrained digital documents using cryptography, especially through the use of digital signatures and related mathematical proofs.

while the related [Controlled Identifiers](https://www.w3.org/TR/cid-1.0/) specification appears to build on the earlier [Decentralized Identifiers specification](https://www.w3.org/TR/did-1.0/), defining a more general controlled identifier document as:

> A controlled identifier document contains cryptographic material and lists service endpoints for the purposes of verifying cryptographic proofs from, and interacting with, the controller of an identifier.

Decentralised Identifiers (DIDs) are a very interesting area and a central part of Verifiable Credentials and therefore the UNTP as well.

I hope that provides enough background information and links to some of the technical specifications that are underpinning the United Nations Transparency Protocol, in particular, for **Verifiable Credentials**, **JSON Linked Data** and **Decentralized Identifiers**), so that anyone interested in learning more or wanting to get involved can do so. I'll be following up with a more technical deep-dive into a proof-of-concept tool that I worked on recently that is able to benefit from the JSON-LD format used for verifiable credentials to build trust information from graphs of UNTP data.
