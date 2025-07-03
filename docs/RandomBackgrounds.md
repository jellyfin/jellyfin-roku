# Random Movie Backgrounds Feature

This feature adds randomized movie backdrop images to the main home screen background, providing a dynamic and visually appealing interface.

## How it Works

1. **Fetches Movie Data**: The system queries the Jellyfin server for movies that have backdrop images
2. **Randomizes Selection**: A random movie is selected from the available options
3. **Updates Background**: The backdrop image from the selected movie is set as the home screen background
4. **Applies Overlay**: A translucent black overlay is applied on top of the background image for better text readability
5. **Auto-Refresh**: The background automatically changes every 2 minutes (configurable)

## Configuration

The feature supports the following user settings:

- `enableRandomBackgrounds` (boolean, default: true) - Enable/disable the random backgrounds feature
- `backgroundChangeInterval` (integer, default: 120) - Time in seconds between background changes
- `backgroundOverlayOpacity` (float, default: 0.92) - Opacity of the black overlay on top of background images (0.0 = transparent, 1.0 = opaque)
- `backgroundOverlayColor` (string, default: "0x000000") - Color of the overlay in hexadecimal format

## Implementation Details

### Files Created/Modified:

1. **components/home/Home.bs** - Main home screen component
   - Added random background initialization
   - Added timer for periodic background changes
   - Added configuration support
   - Added backdrop overlay configuration and management

2. **components/home/RandomBackgroundTask.xml** - Task component XML definition
   - Defines the background task interface

3. **components/home/RandomBackgroundTask.bs** - Background task implementation
   - Handles API calls to fetch movie data
   - Filters movies with backdrop images
   - Returns random backdrop URL

### Key Functions:

- `setRandomBackground()` - Initiates the background fetching process
- `onBackdropURLChanged()` - Callback that updates the UI when new backdrop is ready
- `onBackgroundTimerFired()` - Timer callback for periodic updates
- `updateBackdropOverlay()` - Updates overlay settings (opacity and color)
- `fetchRandomMovieBackdrop()` - Core logic for fetching and selecting random movie backdrop

## Performance Considerations

- Uses asynchronous task execution to avoid blocking the UI
- Limits API queries to 50 movies at a time
- Caches backdrop URLs to reduce server load
- Only updates when home screen is active
- 2-minute refresh interval provides dynamic visual experience without excessive server load

## Timer Configuration Examples

You can customize the background change frequency by setting `backgroundChangeInterval`:

- **Very Frequent** (30 seconds): `backgroundChangeInterval: 30`
- **Frequent** (1 minute): `backgroundChangeInterval: 60`
- **Default** (2 minutes): `backgroundChangeInterval: 120`
- **Moderate** (5 minutes): `backgroundChangeInterval: 300`
- **Slow** (10 minutes): `backgroundChangeInterval: 600`
- **Very Slow** (30 minutes): `backgroundChangeInterval: 1800`

## Future Enhancements

Potential improvements could include:

- User preference for specific movie genres
- Transition animations between background changes
- Support for TV show backdrops in addition to movies
- Local caching of backdrop images
- Fade-in effects for new backgrounds
