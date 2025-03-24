# Contributing to Al-Mosque Portal Themes

Thank you for considering contributing to Al-Mosque Portal Themes! This document provides guidelines and steps for contributing to this project.

## Code of Conduct

Be respectful to others. Harassment and abuse are never tolerated. By participating in this project, you agree to abide by these principles.

## How Can I Contribute?

### Reporting Bugs

- Check if the bug has already been reported in the Issues section
- If not, create a new issue with a descriptive title and clear description
- Include steps to reproduce the issue, expected behavior, and actual behavior
- Add screenshots if applicable

### Suggesting Enhancements

- Check if the enhancement has already been suggested in the Issues section
- If not, create a new issue with a descriptive title and clear description
- Describe the current behavior and explain the desired behavior
- Explain why this enhancement would be useful

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Run tests to ensure they pass
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

## Development Setup

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

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or fewer
- Reference issues and pull requests after the first line

### Elixir Styleguide

Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide).

### Documentation

- Use [ExDoc](https://github.com/elixir-lang/ex_doc) for documentation
- Document all public modules and functions
- Write clear, concise comments and documentation strings

## Additional Notes

### Issue and Pull Request Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `help wanted`: Extra attention is needed
- `good first issue`: Good for newcomers 