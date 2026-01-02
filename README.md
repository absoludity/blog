### Quick Commands

```bash
# Check all markdown files
vale content/**/*.md

# Check only errors
vale --minAlertLevel=error content/**/*.md

# Check a specific file
vale content/post/my-post/index.md

# Sync Vale packages (if needed)
vale sync
```


### Ignoring False Positives

```markdown
<!-- vale off -->
This text won't be checked at all.
<!-- vale on -->

<!-- vale Blog.BritishSpelling = NO -->
You can license pilots here (verb usage is correct).
<!-- vale Blog.BritishSpelling = YES -->
```
