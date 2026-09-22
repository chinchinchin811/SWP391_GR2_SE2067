/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import model.Flashcard.Flashcard;
import model.Flashcard.FlashcardDeck;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author HP
 */
public class FlashcardDAO {

    public List<FlashcardDeck> getAllDecks() {
        List<FlashcardDeck> list = new ArrayList<>();
        String sql = "SELECT * FROM FlashcardDecks ORDER BY created_at DESC";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FlashcardDeck d = new FlashcardDeck();
                d.setDeckId(rs.getInt("deck_id"));
                d.setTitle(rs.getString("title"));
                d.setDescription(rs.getString("description"));
                list.add(d);
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
                    Flashcard c = new Flashcard();                   
                    c.setCardId(rs.getInt("card_id"));                   
                    c.setDeckId(rs.getInt("deck_id"));
                    c.setQuestion(rs.getString("question"));
                    c.setAnswer(rs.getString("answer"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
