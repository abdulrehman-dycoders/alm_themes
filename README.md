# Al-Mosque Portal Themes

A collection of responsive prayer time display themes for mosques, Islamic centers, and educational institutions. This app provides beautiful, customizable displays for prayer times, iqamah times, and other mosque-related information.

## Features

- Multiple theme options for displaying prayer times
- Real-time countdown to next prayer
- Dynamic date and time display
- Responsive design for different screen sizes
- SVG icons for different prayer times
- Customizable messaging

## Prerequisites

- Elixir 1.14 or later
- Phoenix 1.7 or later
- Node.js 16 or later (for asset compilation)

## Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/almosque_portal_themes.git
   cd almosque_portal_themes
   ```

2. Install dependencies
   ```
   mix deps.get
   cd assets && npm install && cd ..
   ```

3. Set up the database
   ```
   mix ecto.setup
   ```

4. Start Phoenix server
   ```
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Available Themes

- White Iqamah Only: A clean white theme showing only Iqamah times
- (Add other themes as they become available)

## Configuration

Prayer times and other settings can be configured in the respective theme files located in `lib/almosque_portal_themes_web/live/`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
