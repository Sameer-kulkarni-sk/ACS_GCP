# Contributors Guide

Thank you for your interest in contributing to the GCP Compare Project!

## How to Contribute

### Reporting Issues

1. Check if issue already exists
2. Provide clear, detailed description
3. Include steps to reproduce
4. Specify environment (OS, Node.js version, etc.)

### Suggesting Enhancements

1. Use a clear, descriptive title
2. Provide detailed description
3. Explain the motivation
4. List possible alternatives

### Code Contributions

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Implement** your changes
4. **Test** thoroughly
   ```bash
   npm install
   npm test
   npm run gae:local  # Test locally
   ```
5. **Commit** with clear messages
   ```bash
   git commit -m "Add feature: clear description"
   ```
6. **Push** to your fork
7. **Create** a Pull Request

## Development Setup

```bash
# Clone repository
git clone https://github.com/your-username/gcp-compare-project.git
cd gcp-compare-project

# Install dependencies
npm install

# Run locally
npm run dev

# Run tests
npm test

# Build Docker image
docker build -t gcp-compare-app:dev .
```

## Code Standards

### JavaScript/Node.js
- Use ES6+ syntax
- Follow existing code style
- Add JSDoc comments for functions
- Keep functions small and focused

### Kubernetes YAML
- Use 2-space indentation
- Follow Kubernetes naming conventions
- Comment complex configurations
- Include resource limits

### Documentation
- Use clear, concise language
- Include examples
- Keep formatting consistent
- Update README if needed

## Testing

### Local Testing
```bash
# App Engine
npm run gae:local

# GKE Simulation
npm run gke:local

# Health check
curl http://localhost:8080/health

# API endpoints
curl http://localhost:8080/api/info
```

### Deployment Testing
```bash
# Test on App Engine
gcloud app deploy
gcloud app browse

# Test on GKE (requires cluster)
make deploy-gke
kubectl get pods
```

## Pull Request Process

1. Update README/docs if needed
2. Add tests for new features
3. Ensure code passes linting
4. Provide clear PR description
5. Link related issues
6. Wait for review and feedback

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
Describe testing performed:
- [ ] Tested locally
- [ ] Tested on GAE
- [ ] Tested on GKE

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes

## Screenshots (if applicable)
Add screenshots for UI changes
```

## Documentation Contributions

### Updating Docs

1. Edit markdown files in `/docs`
2. Use clear headings and examples
3. Include code snippets where helpful
4. Test links and references
5. Update table of contents

### Adding New Documentation

1. Create new `.md` file in `/docs`
2. Follow existing format/style
3. Include in README navigation
4. Link from other relevant docs

## Commit Message Guidelines

```
[TYPE]: Clear, concise subject line (50 chars max)

Detailed description explaining:
- What changed and why
- How it works
- Any implications

Fixes #ISSUE_NUMBER
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Test additions/updates
- `chore`: Build, dependencies, etc.

## Code Review Guidelines

### For Contributors
- Respond to feedback promptly
- Make requested changes
- Ask questions if unclear
- Be open to suggestions

### For Reviewers
- Be constructive and respectful
- Suggest improvements
- Approve when satisfied
- Merge when ready

## Release Process

1. Update version in `package.json`
2. Update `CHANGELOG.md`
3. Tag release: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create release on GitHub

## Getting Help

- **Documentation**: See `/docs` directory
- **Issues**: Search existing issues
- **Discussions**: Create discussion thread
- **Email**: Maintainer contact info

## Code of Conduct

This project adheres to the Contributor Covenant. By participating, you agree to:
- Be respectful and inclusive
- Welcome diverse perspectives
- Provide constructive feedback
- Report violations respectfully

## License

By contributing, you agree your contributions are licensed under the MIT License.

---

Thank you for helping improve this project!

