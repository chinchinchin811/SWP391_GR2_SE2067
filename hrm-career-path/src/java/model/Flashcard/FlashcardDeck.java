
package model.Flashcard;

import java.sql.Timestamp;

/**
 *
 * @author HP
 */
public class FlashcardDeck {

    private int deckId;
    private String title;
    private String description;
    private Timestamp createdAt;

    public FlashcardDeck() {
    }

    public int getDeckId() {
        return deckId;
    }

    public void setDeckId(int deckId) {
        this.deckId = deckId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
