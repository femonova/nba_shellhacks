# README

BestGameFinder is a simple rails app that lets you find every active NBA player's best career games, with a corresponding link to highlights.* There are over 450 active NBA players and 5500 career-best box scores on our app.

<sub>* links to highlights implemented but unstable, may link to wrong player, wrong game or something just plain wrong!</sub>
#### Getting Started
The web app is live at http://bestgamefinder.herokuapp.com

#### Motivation

We were interested in providing a service that lets users quickly and easily search for their favorite active NBA player's best box scores, with a link to highlight clips, all on one centralized web application.

#### Development

We started by designing our schema and identifying 3 main models -- Players, Games, and Links. The relationships are straightforward:
- Player has_many Games
- Game has_many Links
#### APIs and Web Scraping
We needed data for our project, and found a useful API with up-to-date information on current players' teams and positions (Endpoint:  http://data.nba.net/json/cms/noseason/team/pistons/roster.json ). We parsed through and imported the json data into our production PostgreSQL database.

We did not find a free API service that provided each player's career game statistics, so we wrote a Ruby script to web scrape the great https://www.basketball-reference.com . We parsed through every game in every active player's career to find their best 10-15 games (using Game Score as our metric), and stored these games in our database.

Using Google's Youtube Data API, we attempted to collect links to highlights for each player's best couple of games.

#### Future Development

Future work on BestGameFinder might include:

- Finish script to import and insert youtube highlight urls into our database, so we can have links to highlights on major games.
- Make our player & game data accessible as a RESTful API
- Import non-active NBA players and their 10-15 best games.
- Add update scripts and attach a scheduler so our data remains fresh and up-to-date
- Create our own metric that might factor in game importance (i.e. during playoffs as opposed to a game in November), a clutch factor (if player involved in winning play in last 10 seconds of game) and other uncommon stats.

#### Project Members

- Joe Knight - Lead Programmer (Back-end development, web scraping, database design, project setup and project manager)
- Austin Montes - Database Designer, API endpoint research, front-end development)
- Olufemi Adeshina - Front-end developer (HTML & CSS)
- Snyder Petit - General Design Feedback
