# Documentation Style

Write competent prose, not shopping lists with a technical guise.

## The problem

AI-generated documentation reads like a toddler dumped a database. Everything is atomicised, bulleted, processed, synthesised. Vague words like "handles", "manages", "provides" substitute for actual explanations.

This is a chore to read, there's no intrigue. Users need information dense and useful enough to be worth their time.

## Principles

✓ Prose carries ideas and teaches. Bullets itemise; sentences explain. If you're describing, write prose. Only pull out lists for genuine sets of data or actual step-by-step procedures.
✓ When communicating, express the most information in the least time. Maintain correct grammar and engaging flow.
✓ Fewer headings. A heading every 50 words fragments reading. Combine related ideas into substantial sections. If a section can't sustain a few sentences, it probably doesn't need its own heading.
✓ Assume competence. Don't hand-hold. Don't explain that filepaths are things on disk. Start at the reader's actual knowledge level and stay there.
✓ Lead with the point. Open sections with what matters, background comes after. If the reader stops at paragraph one, they should still have learned something.
✓ Show before tell. Code examples first, explanation after. The example demonstrates; the prose clarifies the 'why' and 'how' without following a cookie-cutter heading template.
✓ Vary rhythm. Some sentences should be short. Others can develop a thought across multiple clauses, building context before landing on the conclusion.
✓ Earned cynicism that demonstrates experience. A dry observation about a genuine problem builds credibility, say so plainly.

## Technical precision

✓ Name the mechanism. Don't say "imp handles this automatically"; say "imp recursively walks the directory tree and converts each `.nix` file to an attrset path".
✓ Specify the transformation. "Directories become nested attrsets" is better than "the structure is preserved".
✓ Use domain vocabulary. If there's a correct term (attrset, derivation, module system, fixed-point), use it. Readers can look it up; vagueness they cannot.
✓ Describe behavior, not personality. The code doesn't "know" or "understand" or "recognize". It pattern-matches, recurses, evaluates.
✓ Quantify when possible. "Three levels deep" beats "nested". "Fails at eval time with 'attribute missing'" beats "will error".

## AVOID

✗ Em dashes and hyphens for joining clauses
✗ Hollow verbs: "handles", "manages", "provides", "enables", "facilitates", "leverages"
✗ Anthropomorphising code: "imp knows", "the system understands", "it figures out"
✗ Vague qualifiers: "special", "smart", "automatic", "seamless", "powerful"
✗ Excessive chunking and markdown decoration
✗ Enumerating heading... code block... list... heading... code block... list... ad-nauseam
✗ Starting lists with a bold prefix
✗ Symptom/cause/solution templates for every edge case
✗ Explaining what you're about to explain, then explaining it

## Test

Read your draft aloud. Can you explain what actually happens, mechanically? If you've written "handles X" without saying how, rewrite it. How much fluff could be cut without sacrificing comprehension? Documentation can be precise and technical while maintaining a human quality to the craft.
