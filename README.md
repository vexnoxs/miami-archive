# miami-archive

Sito statico di **MIAMI / MiamiArchive**: client, resource pack, shader, profili, mod e news per Minecraft.

## Struttura

- `data.json` — voci di tutte le categorie e le news
- `template.html` — shell comune delle pagine (navbar, footer, sfondo)
- `partials/home.html` — contenuto della home (hero + features)
- `build.ps1` — genera le pagine statiche da template + dati
- `style.css`, `app.js` — stile e interazioni

## Come aggiornare

1. Modifica `data.json` (aggiungi/rimuovi voci) o `partials/home.html`
2. Rigenera le pagine: `powershell -File build.ps1`
3. Commit e push:

```
git add -A
git commit -m "descrizione"
git push origin main
```