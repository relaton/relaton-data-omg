# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

relaton-data-omg crawls the OMG Specifications Catalog (https://www.omg.org/spec)
into `data/*.yaml` Relaton records, builds the two index flavours over them, and
publishes the machine index on GitHub Pages — the relaton#206 shape (manifest +
per-query shards served by the shared `relaton/support` data-deploy workflow).

## Architecture

- `lib/omg_fetcher.rb` — the fetcher. `Catalog` enumerates the catalog: the
  landing page's JSON-LD `@imports` block lists every spec's About page (the
  acronym list, no listing markup to scrape), and each About page links the
  spec's version pages (`/spec/<ACRO>/<VERSION>`, spaces as slashes).
  `Build` delegates ALL per-page parsing to `Relaton::Omg::Scraper` (in the
  relaton gem) — the fetcher only enumerates, persists, and warns-and-skips
  on unparseable refs. `Indexer` builds index-v1 (string docid) and index-v2
  (structured `Pubid::Omg`) in one pass over `data/*.yaml`, then zips each.
- `crawler.rb` — the entry point the shared crawler workflow runs; it commits
  `index*.yaml` / `index*.zip`.
- `check_data.rb` — round-trip validator over `data/` (run by check-index.yml
  before publish).
- `.github/workflows/` — Cimas-synced fleet templates: `crawler.yml` (daily
  14:00 UTC + dispatch), `deploy.yml` (publishes Pages after a crawl), 
  `check-index.yml` (PR-time build, no Pages), `keep-alive.yml`,
  `api-relaton-dispatch.yml`. Per-repo branding lives in relaton/support's
  `data-index/configs.yml` — never in these files.

## OMG-specific notes

- The OMG gem deliberately shipped WITHOUT an index ("OMG publishes no index
  and has no data repository — do not add an index"): this repo is what
  changes that. The gem side's consumer flip to the machine index
  (`Relaton::Omg::PAGES_URL`) is the follow-up.
- The catalog URL keeps only the acronym and the version
  (`https://www.omg.org/spec/<ACRONYM>/<VERSION>`), each space of the version
  a slash (`1.0 beta 2` → `1.0/beta/2`). Parts stay out of the URL.
- An unparseable reference is a skipped row, not a failed crawl — the same
  policy as the Indexer's unparseable-id rows.

## Commands

- `bundle install`
- `bundle exec rspec`
- `bundle exec ruby crawler.rb` — full crawl + index build (expensive; the
  workflow runs it, you usually don't want to)
- `bundle exec ruby crawler.rb`-style partial crawl: `OmgFetcher::Build.run(store:, acronyms: ["UML"])`
- `bundle exec ruby check_data.rb`
