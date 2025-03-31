# Auto Body Res

## [v1.2.1](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.2.1) (2025-03-30)

- Updating all brawl and battleground conditional logic
- Update toc

## [v1.1.9](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.9) (2024-12-20)

- Drag and Click control updates to ensure click through when hidden or locked
- Fixing font dropdown list
- Updating font size range
- Minor Cleanup
- Update toc

## [v1.1.8](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.8) (2024-12-10)

- Refactoring map check to use instanceID and brawlID instead of names for cross region support
- Refactoring options setup to be more streamlined and to use a new db change function
- Update all map option to be fully inclusive of all possible maps and brawls

## [v1.1.7](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.7) (2024-11-04)

- Fixing placeholder text hide/show settings

## [v1.1.6](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.6) (2024-11-04)

- Updating placeholder text to be clear its placeholder
- Ensuring when you have placeholder text enabled for placement that it always shows back up when out of instances and when not dead if enabled outside battlegrounds

## [v1.1.5](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.5) (2024-11-04)

- Creating all new settings to control which battleground modes to disable in
- Creating all new settings to control which battleground map to disable in
- Updating other setting labels to be more clear on what they do

## [v1.1.4](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.4) (2024-10-27)

- Update toc

## [v1.1.3](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.3) (2024-10-02)

- Double ensures that if you toggle battleground only mode it wont load in arena and even if it did it hides any previous death text
- adds a check in the start of a message being shown as well to ensure you're in a battleground if that option is enabled
- showing/hiding the text if changing the battleground only setting while dead
- unregisters events at appropriate times so no accidental triggers run and hides at the same time as well
- reduces the default text size a little

## [v1.1.2](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.2) (2024-09-03)

- Adding new setting to turn off body res text

## [v1.1.1](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.1) (2024-09-03)

- Fixing error
- Removing unused type

## [v1.1.0](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.1.0) (2024-09-02)

- Refactor lib usage to match what im doing on BGWC addon to reduce needed libs and global db issues
- Made it so you can't open the settings when locked and right clicking the text
- Minor random changes based on learning from BGWC

## [v1.0.8](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.8) (2024-05-08)

- Fixing 10.2.7 bugs for incorrect setting of text justification
- Unregistering events from pvp if toggled off

## [v1.0.7](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.7) (2024-01-09)

- adding slash command support

## [v1.0.6](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.6) (2024-01-08)

- fixing movement bug after locking into place

## [v1.0.5](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.5) (2024-01-08)

- removing the auto-res 1s delay from the timer

## [v1.0.4](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.4) (2024-01-08)

- adding new option to turn off bg only mode
- updating option text

## [v1.0.2](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.2) (2024-01-08)

- updating wago id

## [v1.0.1](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.1) (2024-01-08)

- update lib usage

## [v1.0.0](https://github.com/rbgdevx/auto-body-res/releases/tag/v1.0.0) (2024-01-08)

- initial release
