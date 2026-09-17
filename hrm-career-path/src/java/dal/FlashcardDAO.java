/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author HP
 */
import model.Flashcard;
import model.FlashcardDeck;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FlashcardDAO {

    public List<FlashcardDeck> getAllDecks() {
        List<FlashcardDeck> list = new ArrayList<>();
        String sql = "SELECT * FROM FlashcardDecks ORDER BY created_at DESC";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FlashcardDeck deck = new FlashcardDeck();
                deck.setDeckId(rs.getInt("deck_id"));
                deck.setTitle(rs.getString("title"));
                deck.setDescription(rs.getString("description"));
                deck.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(deck);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Flashcard> getCardsByDeckId(int deckId) {
        List<Flashcard> list = new ArrayList<>();
        String sql = "SELECT * FROM Flashcards WHERE deck_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Flashcard card = new Flashcard();
                    card.setCardId(rs.getInt("card_id"));
                    card.setDeckId(rs.getInt("deck_id"));
                    card.setQuestion(rs.getString("question"));
                    card.setAnswer(rs.getString("answer"));
                    list.add(card);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
