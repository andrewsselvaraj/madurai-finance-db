package com.maduraifinance.web;

import com.maduraifinance.service.CollectionService;
import com.maduraifinance.service.CurrentUser;
import com.maduraifinance.web.dto.CollectionDtos;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/collections")
public class CollectionController {

    private final CollectionService collectionService;
    private final CurrentUser currentUser;

    public CollectionController(CollectionService collectionService, CurrentUser currentUser) {
        this.collectionService = collectionService;
        this.currentUser = currentUser;
    }

    @GetMapping
    public List<CollectionDtos.Collection> list() {
        return collectionService.list(currentUser.get());
    }

    @GetMapping("/collectable-loans")
    public List<CollectionDtos.CollectableLoan> collectableLoans() {
        return collectionService.collectableLoans(currentUser.get());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CollectionDtos.Collection create(@Valid @RequestBody CollectionDtos.CreateCollectionRequest req) {
        return collectionService.create(currentUser.get(), req);
    }
}
